class Option {
  final String ticker;
  final String underlyingTicker;
  final String contractType;
  final double strikePrice;
  final String expirationDate;
  final String exerciseStyle;
  final String primaryExchange;
  final int sharesPerContract;

  // market data TODO
  final double? bid;
  final double? ask;
  final double? lastPrice;
  final double? volume;
  final double? openInterest;
  final double? impliedVolatility;
  final double? delta;
  final double? gamma;
  final double? theta;
  final double? vega;

  Option({
    required this.ticker,
    required this.underlyingTicker,
    required this.contractType,
    required this.strikePrice,
    required this.expirationDate,
    required this.exerciseStyle,
    required this.primaryExchange,
    required this.sharesPerContract,
    this.bid,
    this.ask,
    this.lastPrice,
    this.volume,
    this.openInterest,
    this.impliedVolatility,
    this.delta,
    this.gamma,
    this.theta,
    this.vega,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      ticker: json['ticker'],
      underlyingTicker: json['underlying_ticker'],
      contractType: json['contract_type'],
      strikePrice: (json['strike_price'] as num).toDouble(),
      expirationDate: json['expiration_date'],
      exerciseStyle: json['exercise_style'] ?? 'american',
      primaryExchange: json['primary_exchange'] ?? '',
      sharesPerContract: json['shares_per_contract'] ?? 100,
      // Market data if available
      bid: json['bid']?.toDouble(),
      ask: json['ask']?.toDouble(),
      lastPrice: json['last_price']?.toDouble(),
      volume: json['volume']?.toDouble(),
      openInterest: json['open_interest']?.toDouble(),
      impliedVolatility: json['implied_volatility']?.toDouble(),
      delta: json['greeks']?['delta']?.toDouble(),
      gamma: json['greeks']?['gamma']?.toDouble(),
      theta: json['greeks']?['theta']?.toDouble(),
      vega: json['greeks']?['vega']?.toDouble(),
    );
  }

  @override
  String toString() {
    return 'Option(ticker: $ticker, type: $contractType, strike: $strikePrice, exp: $expirationDate)';
  }

  double? get midPrice {
    if (bid != null && ask != null) {
      return (bid! + ask!) / 2;
    }
    return null;
  }

  double? get bidAskSpread {
    if (bid != null && ask != null) {
      return ask! - bid!;
    }
    return null;
  }
}
