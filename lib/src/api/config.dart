class ApiConfig {
  static const String baseUrl = 'https://api.polygon.io';
  static const String optionsReferenceBaseEndpoint = '/v3/reference/options';
  static const String optionsEndpoint =
      '$optionsReferenceBaseEndpoint/contracts';
  static const String optionsSnapshotBaseEndpoint = '/v3/snapshot/options';
  static const String optionsContractEndpoint =
      '/v3/reference/options/contracts';
  static const String dailyTickerEndpoint = '/v1/open-close';
  static const String aggsBaseEndpoint = '/v2/aggs/ticker';

  // static const String optionDetailsEndpoint = '/v3/snapshot/options/contracts';

  final String apiKey;

  ApiConfig({required this.apiKey});

  Uri buildOptionsContractUrl({
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

  Uri buildOptionsChainUrl({
    required String ticker,
    String? expirationDate,
    int limit = 250, // max
    String? sort,
  }) {
    final params = {
      'apiKey': apiKey,
      'limit': limit.toString(),
      if (expirationDate != null) 'expiration_date': expirationDate,
      // Can also do
      // if (expirationDateGte != null) 'expiration_date.gte': expirationDateG
      if (sort != null) 'sort': sort,
    };

    return Uri.parse(
      "$baseUrl$optionsSnapshotBaseEndpoint/$ticker",
    ).replace(queryParameters: params);
  }

  Uri buildOptionContractUri({required String ticker}) {
    final params = {"apiKey": apiKey};
    return Uri.parse(
      "$baseUrl$optionsContractEndpoint/$ticker",
    ).replace(queryParameters: params);
  }

  Uri buildDailyTickerPriceUrl({
    required String ticker,
    required String date,
    bool? adjusted = true,
  }) {
    final params = {'apiKey': apiKey, 'adjusted': adjusted.toString()};
    // final encodedTicker = Uri.encodeComponent(optionTicker);
    return Uri.parse(
      "$baseUrl$dailyTickerEndpoint/$ticker/$date",
    ).replace(queryParameters: params);
  }

  Uri buildTickerPrevUri({required String ticker, bool? adjusted = true}) {
    final params = {'apiKey': apiKey, 'adjusted': adjusted.toString()};
    return Uri.parse(
      "$baseUrl$aggsBaseEndpoint/$ticker/prev",
    ).replace(queryParameters: params);
  }

  Uri buildCustomBarsUri({
    required String ticker,
    required int multiplier,
    required String timespan, // make this an Enum
    required String from,
    required String to,
    bool? adjusted = true,
    String? sort = 'asc',
    int? limit = 5000,
  }) {
    final params = {
      'apiKey': apiKey,
      'adjusted': adjusted.toString(),
      'sort': sort,
      'limit': limit.toString(),
    };
    return Uri.parse(
      "$baseUrl$aggsBaseEndpoint/$ticker/range/$multiplier/$timespan/$from/$to",
    ).replace(queryParameters: params);
  }
}
