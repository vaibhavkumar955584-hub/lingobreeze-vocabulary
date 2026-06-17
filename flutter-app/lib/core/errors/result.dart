/// A generic Result wrapper for standard success/failure operations.
/// Utilizes Dart 3 sealed class mechanisms.
sealed class Result<S, F> {
  const Result();

  /// Utility to check if is success
  bool get isSuccess => this is Ok<S, F>;

  /// Utility to check if is failure
  bool get isFailure => this is Err<S, F>;

  /// Fold both options to return a single computed value.
  T fold<T>(T Function(S success) onSuccess, T Function(F failure) onFailure) {
    return switch (this) {
      Ok<S, F>(value: final val) => onSuccess(val),
      Err<S, F>(error: final err) => onFailure(err),
    };
  }
}

class Ok<S, F> extends Result<S, F> {
  final S value;
  const Ok(this.value);
}

class Err<S, F> extends Result<S, F> {
  final F error;
  const Err(this.error);
}
