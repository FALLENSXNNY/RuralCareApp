// Error handler — converts technical errors to user-friendly messages
import 'app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  /// Converts any error/exception to a user-friendly AppException.
  static AppException handle(Object error, {String? context}) {
    if (error is AppException) {
      return error;
    }

    // Map common Flutter/Dart errors
    if (error is FormatException) {
      return AppException.validation(
        'The information received was not in the expected format.',
        error,
      );
    }

    // Fallback
    return AppException.unknown(
      context != null ? '$context: $error' : error.toString(),
      error,
    );
  }

  /// Returns a user-friendly message for any error.
  static String message(Object error, {String? fallback}) {
    final appException = handle(error);
    return appException.message;
  }
}
