
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class NetworkException extends ApiException {
  const NetworkException(super.message);

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException extends ApiException {
  const ServerException(super.message, {super.statusCode});

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}


class ParseException extends ApiException {
  const ParseException(super.message);

  @override
  String toString() => 'ParseException: $message';
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}
