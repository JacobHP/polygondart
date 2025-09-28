import 'dart:convert';
import 'package:http/http.dart' as http;

import 'config.dart';
import '../models/models.dart';

class PolygonClient {
  final ApiConfig config;
  // logger?

  PolygonClient({required this.config});

  // make it a list of Option
  Future<List<Option>> fetchOptionsChain({
    required String ticker,
    required String expirationDate,
    int? limit,
  }) async {
    final uri = config.buildOptionsChainUrl(
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
}

void main() async {
  print('Testing client...');

  final config = ApiConfig(apiKey: 'foobar');
  final client = PolygonClient(config: config);

  final options = await client.fetchOptionsChain(
    ticker: 'AAPL',
    expirationDate: '2025-10-03',
  );
  print('Options fetched: ${options[0]}');
}
