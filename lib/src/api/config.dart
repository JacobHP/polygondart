class ApiConfig {
  static const String baseUrl = 'https://api.polygon.io';
  static const String optionsEndpoint = '/v3/reference/options/contracts';
  static const String optionDetailsEndpoint = '/v3/snapshot/options/contracts';

  final String apiKey;

  ApiConfig({required this.apiKey});

  Uri buildOptionsChainUrl({
    required String ticker,
    String? expirationDate,
    int limit = 1000,
    String? sort,
  }) {
    final params = {
      'underlying_ticker': ticker,
      'apiKey': apiKey,
      'limit': limit.toString(),
      if (expirationDate != null) 'expiration_date': expirationDate,
      if (sort != null) 'sort': sort,
    };

    return Uri.parse(
      baseUrl + optionsEndpoint,
    ).replace(queryParameters: params);
  }
}
