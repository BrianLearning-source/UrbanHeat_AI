/// A typed failure returned by a repository instead of throwing to its caller.
sealed class Failure {
  const Failure();
}

/// A failure caused by a network or remote service operation.
final class NetworkFailure extends Failure {
  const NetworkFailure();
}

/// A failure caused by local persistence or device storage.
final class LocalFailure extends Failure {
  const LocalFailure();
}

/// A failure that does not fit a more specific category.
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();
}
