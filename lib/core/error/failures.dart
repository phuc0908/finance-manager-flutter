import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

// Auth failures
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

// Database failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
