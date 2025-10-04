class PolygonApiException implements Exception {
  final int statusCode;
  final String message;
  final String? responseBody;

  PolygonApiException({
    required this.statusCode,
    required this.message,
    this.responseBody,
  });

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class RateLimitException extends PolygonApiException {
  // retryAfter possibly?
  RateLimitException({
    required super.statusCode,
    required super.message,
    super.responseBody,
  });
}

class AuthorizationException extends PolygonApiException {
  AuthorizationException({
    required super.statusCode,
    required super.message,
    super.responseBody,
  });
}

class BadRequestException extends PolygonApiException {
  BadRequestException({
    required super.statusCode,
    required super.message,
    super.responseBody,
  });
}

class LargeRequestException extends PolygonApiException {
  LargeRequestException({
    required super.statusCode,
    required super.message,
    super.responseBody,
  });
}

class NotFoundException extends PolygonApiException {
  NotFoundException({
    required super.statusCode,
    required super.message,
    super.responseBody,
  });
}

class ServerException extends PolygonApiException {
  ServerException({
    required super.statusCode,
    required super.message,
    super.responseBody,
  });
}
