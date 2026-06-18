/// Represents error conditions in the system.
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A cache/storage error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'A network connection issue occurred.',
  ]);
}

class FirebaseFailure extends Failure {
  const FirebaseFailure([super.message = 'A database error occurred.']);
}
