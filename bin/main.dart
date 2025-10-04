import 'dart:io';
import 'package:args/args.dart';
import 'package:dotenv/dotenv.dart';

import 'package:polygondart/polygondart.dart' as polygondart;
import 'package:polygondart/src/api/config.dart';
import 'package:polygondart/src/api/polygon_client.dart';

// entry with a ticker and expiration date to get the options chain
void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption(
      'ticker',
      abbr: 't',
      help: 'Stock ticker symbol',
      mandatory: true,
    )
    ..addOption(
      'expiration',
      abbr: 'e',
      help: 'Expiration date (YYYY-MM-DD)',
      mandatory: true,
    )
    ..addFlag('help', abbr: 'h', help: 'Show help', negatable: false);

  ArgResults argResults;
  try {
    argResults = parser.parse(arguments);
  } catch (e) {
    print('Error: $e\n');
    print(parser.usage);
    exit(1);
  }

  if (argResults['help'] as bool) {
    print('Polygon options chain fetcher\n');
    print(parser.usage);
    exit(0);
  }

  final env = DotEnv(includePlatformEnvironment: true)..load();
  final apiKey = env['POLYGON_API_KEY'];

  if (apiKey == null) {
    print('Error: Polygon API key not found in environment');
    exit(1);
  }
  // final config = null;
  // final client = null;
  // final optionsService = null;

  try {
    final ticker = argResults['ticker'] as String;
    final expiration = argResults['expiration'] as String;

    print(
      'Fetching options data for ticker: $ticker and expiration $expiration',
    );
    final config = ApiConfig(apiKey: apiKey);
    final client = PolygonClient(config: config);

    final options = await client.fetchOptionsContracts(
      ticker: ticker,
      expirationDate: expiration,
    );
    print("Fetched options ${options.take(3)}...");
  } catch (e) {
    print('Error: $e');
    exit(1);
  }
}
