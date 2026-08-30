sealed class AppFailure {
  final String message;
  const AppFailure(this.message);
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class ServerFailure extends AppFailure {
  const ServerFailure([super.message = 'Server error occurred']);
}

class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = 'Resource not found']);
}

class ParseFailure extends AppFailure {
  const ParseFailure([super.message = 'Failed to parse data']);
}

class UnknownFailure extends AppFailure {
  const UnknownFailure([super.message = 'An unknown error occurred']);
}
