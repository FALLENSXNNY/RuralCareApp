// Standardized application exceptions for RuralCare
// These map technical errors to user-friendly messages.

enum AppErrorType {
  network,
  authentication,
  validation,
  notFound,
  server,
  storage,
  unknown,
}

class AppException implements Exception {
  final AppErrorType type;
  final String message;
  final String? technicalDetails;
  final Object? cause;

  const AppException({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.cause,
  });

  factory AppException.network([String? message, Object? cause]) {
    return AppException(
      type: AppErrorType.network,
      message: message ?? "You're offline. Please check your internet connection.",
      cause: cause,
    );
  }

  factory AppException.authentication([String? message, Object? cause]) {
    // The provided string becomes the user-facing [message] so the UI can show
    // the actual reason (e.g. OTP failure) instead of a generic fallback.
    return AppException(
      type: AppErrorType.authentication,
      message: message ?? 'Please sign in to continue.',
      cause: cause,
    );
  }

  factory AppException.validation(String message, [Object? cause]) {
    return AppException(
      type: AppErrorType.validation,
      message: message,
      cause: cause,
    );
  }

  factory AppException.notFound([String? details, Object? cause]) {
    return AppException(
      type: AppErrorType.notFound,
      message: 'The requested information was not found.',
      technicalDetails: details,
      cause: cause,
    );
  }

  factory AppException.server([String? message, Object? cause]) {
    return AppException(
      type: AppErrorType.server,
      message: message ?? "We couldn't complete this request. Please try again.",
      cause: cause,
    );
  }

  factory AppException.storage([String? details, Object? cause]) {
    return AppException(
      type: AppErrorType.storage,
      message: 'Could not save data on this device.',
      technicalDetails: details,
      cause: cause,
    );
  }

  factory AppException.unknown([String? details, Object? cause]) {
    return AppException(
      type: AppErrorType.unknown,
      message: 'Something went wrong. Please try again.',
      technicalDetails: details,
      cause: cause,
    );
  }

  @override
  String toString() {
    final base = 'AppException($type): $message';
    if (technicalDetails != null) return '$base\nDetails: $technicalDetails';
    return base;
  }
}
