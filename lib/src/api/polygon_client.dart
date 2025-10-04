import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:polygondart/src/utils/exceptions.dart';

import 'config.dart';
import '../models/models.dart';
import '../utils/logger.dart';

class PolygonClient {
  final ApiConfig config;
  // logger?

  PolygonClient({required this.config});

  String _sanitizeUri(Uri uri) {
    return uri.toString().replaceAll(config.apiKey, '***API_KEY***');
  }

  Future<Map<String, dynamic>> _makeGetRequest(Uri uri) async {
    logger.fine("Making get request to fetch data from ${_sanitizeUri(uri)}");

    final response = await http.get(uri);
    logger.fine("Response status: ${response.statusCode}");

    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }

    final responseBody = response.body;
    final statusCode = response.statusCode;
    logger.severe("Request failed with status $statusCode");
    logger.severe("Response message: $responseBody");

    switch (statusCode) {
      case 400:
        throw BadRequestException(
          statusCode: statusCode,
          message: "Bad request - check your parameters",
          responseBody: responseBody,
        );

      case 401:
      case 403:
        throw AuthorizationException(
          statusCode: statusCode,
          message: "Access forbidden - check API key and API permissions",
          responseBody: responseBody,
        );

      case 404:
        throw NotFoundException(
          statusCode: statusCode,
          message: "Resource not found",
          responseBody: responseBody,
        );
      case 413:
        throw LargeRequestException(
          statusCode: statusCode,
          message: "Request content/entity too large",
          responseBody: responseBody,
        );
      case 429:
        throw RateLimitException(
          statusCode: statusCode,
          message: "Too many requests",
          responseBody: responseBody,
        );
      case 500:
      case 503:
        throw ServerException(
          statusCode: statusCode,
          message: "Internal Server Error",
          responseBody: responseBody,
        );
    }
    throw Exception(
      "Failed with status code ${response.statusCode} for ${_sanitizeUri(uri)}",
    );
    // note - want to handle different response codes - retry on timeout etc.
  }

  Future<List<Option>> fetchOptionsContracts({
    required String ticker,
    required String expirationDate,
    int? limit,
  }) async {
    final uri = config.buildOptionsContractUrl(
      ticker: ticker,
      expirationDate: expirationDate,
    );

    final data = await _makeGetRequest(uri);

    final results = data['results'] as List<dynamic>? ?? [];

    return results
        .map((json) => Option.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> fetchOptionsContractOverview({
    required String ticker,
  }) async {
    final uri = config.buildOptionContractUri(ticker: ticker);
    final data = await _makeGetRequest(uri);
    return data;
  } // https://polygon.io/docs/rest/options/contracts/contract-overview

  Future<Map<String, dynamic>> fetchDailyTickerPrice({
    required String ticker,
    required String date,
    bool? adjusted = true,
  }) async {
    final uri = config.buildDailyTickerPriceUrl(
      ticker: ticker,
      date: date,
      adjusted: adjusted,
    );
    final data = await _makeGetRequest(uri);
    return data;
  }

  Future<Map<String, dynamic>> fetchPrevDailyTickerPrice({
    required String ticker,
    bool? adjusted = true,
  }) async {
    final uri = config.buildTickerPrevUri(ticker: ticker, adjusted: adjusted);
    final data = await _makeGetRequest(uri);
    return data;
  } // prev available https://polygon.io/docs/rest/options/aggregates/previous-day-bar
  // good for options

  Future<List<Map<String, dynamic>>> fetchBarsTickerPrice({
    required String ticker,
    required int multiplier,
    required String timespan, // make this an Enum
    required String fromDate,
    required String toDate,
    bool? adjusted = true,
    String? sort = 'asc',
    int? pageLimit = 5000,
  }) async {
    List<Map<String, dynamic>> allResults = [];

    Uri? currentUri = config.buildCustomBarsUri(
      ticker: ticker,
      multiplier: multiplier,
      timespan: timespan,
      from: fromDate,
      to: toDate,
      adjusted: adjusted,
      sort: sort,
      limit: pageLimit,
    );

    while (currentUri != null) {
      logger.fine("Fetching page from ${_sanitizeUri(currentUri)}");

      final data = await _makeGetRequest(currentUri);
      final results = data['results'] as List<dynamic>? ?? [];
      allResults.addAll(results.cast<Map<String, dynamic>>());
      logger.info(
        "Fetched ${results.length} bars (total: ${allResults.length})",
      );

      final nextUrl = data['next_url'] as String?;
      currentUri = nextUrl != null
          ? Uri.parse(nextUrl).replace(
              queryParameters: {
                ...Uri.parse(nextUrl).queryParameters,
                'apiKey': config.apiKey,
              },
            )
          : null;
    }

    logger.info("Finished fetching all bars: ${allResults.length} total");
    return allResults;
  } // prices ina  range and multiplier https://polygon.io/docs/rest/options/aggregates/custom-bars
}

void main() async {
  setUpLogger();
  logger.info('Testing client...');
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['POLYGON_API_KEY'] as String;
  final config = ApiConfig(apiKey: apiKey);
  final client = PolygonClient(config: config);

  final options = await client.fetchBarsTickerPrice(
    // ticker: 'O:AAPL251010C00257500',
    multiplier: 1,
    timespan: "day",
    fromDate: "2025-01-09",
    toDate: "2025-02-10",
    pageLimit: 10,
    ticker: 'AAPL',
    // date: '2025-10-05',
  );
  print('Done');
  logger.info('Options fetched: $options');
}
