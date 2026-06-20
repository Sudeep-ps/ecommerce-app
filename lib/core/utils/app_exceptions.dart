/// Exceptions thrown by the data layer (remote/local data sources).
///
/// These are caught by repositories and translated into [Failure]s before
/// reaching the domain/presentation layers, keeping the UI decoupled from
/// the transport mechanism (Dio, SharedPreferences, etc).
class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'Server error occurred']);
}

class NetworkException implements Exception {
  final String message;
  const NetworkException([this.message = 'No internet connection']);
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'Cache error occurred']);
}
