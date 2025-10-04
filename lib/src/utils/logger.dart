import 'dart:io';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';

void setUpLogger() {
  final env = DotEnv(includePlatformEnvironment: true)..load();
  String? logLevel = Platform.environment['LOG_LEVEL'] ?? env['LOG_LEVEL'];
  ;

  Logger.root.level = parseLogLevel(levelName: logLevel);
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
}

Level parseLogLevel({required String? levelName}) {
  return switch ((levelName ?? 'INFO').toUpperCase()) {
    'ALL' => Level.ALL,
    'FINEST' => Level.FINEST,
    'FINER' => Level.FINER,
    'FINE' => Level.FINE,
    'CONFIG' => Level.CONFIG,
    'INFO' => Level.INFO,
    'WARNING' => Level.WARNING,
    'SEVERE' => Level.SEVERE,
    'SHOUT' => Level.SHOUT,
    'OFF' => Level.OFF,
    _ => Level.INFO,
  };
}

final logger = Logger('PolygonClient');
