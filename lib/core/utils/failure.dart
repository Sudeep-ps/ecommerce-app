import 'package:equatable/equatable.dart';

/// Base class for all "expected" failures in the app.
///
/// We deliberately avoid throwing raw exceptions up to the UI layer.
/// Repositories catch exceptions from data sources and convert them into
/// one of these typed [Failure]s, which the UI can pattern-match on to show
/// an appropriate message (no internet vs. server error vs. unknown).
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
