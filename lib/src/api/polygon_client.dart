import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

import 'config.dart';
import '../models/models.dart';

class PolygonClient {
  final ApiConfig config;
  // logger?

  PolygonClient({required this.config});

  // make it a list of Option
  Future<List<Option>> fetchOptionsContracts({
    required String ticker,
    required String expirationDate,
    int? limit,
  }) async {
    final uri = config.buildOptionsContractUrl(
      ticker: ticker,
      expirationDate: expirationDate,
    );

    print("Fetching from $uri");

    final response = await http.get(uri);
    print("Response: $response");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'] as List<dynamic>? ?? [];

      return results
          .map((json) => Option.fromJson(json as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception("failed for response $response");
    }
  }

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

    print("Fetching from $uri");

    final response = await http.get(uri);
    print("Response: $response");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception(
        "failed with status code ${response.statusCode}for response $response",
      );
    }
  }
}

void main() async {
  print('Testing client...');
  final env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['POLYGON_API_KEY'] as String;
  final config = ApiConfig(apiKey: apiKey);
  final client = PolygonClient(config: config);

  final options = await client.fetchDailyTickerPrice(
    // ticker: 'O:AAPL251010C00257500',
    ticker: 'AAPL',
    date: '2025-10-02',
  );
  print('Options fetched: $options');
}
