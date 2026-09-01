// Unit tests for error handling and configuration
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/config/app_config.dart';
import 'package:ruralcare/core/error/app_exception.dart';
import 'package:ruralcare/core/error/error_handler.dart';

void main() {
  group('AppException', () {
    test('network factory creates network error', () {
      final e = AppException.network();
      expect(e.type, AppErrorType.network);
      expect(e.message, contains('offline'));
    });

    test('authentication factory creates auth error', () {
      final e = AppException.authentication();
      expect(e.type, AppErrorType.authentication);
      expect(e.message, contains('sign in'));
    });

    test('validation factory creates validation error', () {
      final e = AppException.validation('Invalid input');
      expect(e.type, AppErrorType.validation);
      expect(e.message, 'Invalid input');
    });

    test('notFound factory creates not found error', () {
      final e = AppException.notFound();
      expect(e.type, AppErrorType.notFound);
    });

    test('server factory creates server error', () {
      final e = AppException.server();
      expect(e.type, AppErrorType.server);
    });

    test('storage factory creates storage error', () {
      final e = AppException.storage();
      expect(e.type, AppErrorType.storage);
    });

    test('unknown factory creates unknown error', () {
      final e = AppException.unknown();
      expect(e.type, AppErrorType.unknown);
    });

    test('toString includes type and message', () {
      final e = AppException.network();
      expect(e.toString(), contains('AppException'));
      expect(e.toString(), contains('network'));
    });
  });

  group('ErrorHandler', () {
    test('passes through AppException', () {
      final original = AppException.validation('Test');
      final handled = ErrorHandler.handle(original);
      expect(handled, same(original));
    });

    test('maps FormatException to validation error', () {
      final handled = ErrorHandler.handle(FormatException('bad'));
      expect(handled.type, AppErrorType.validation);
    });

    test('maps unknown errors to unknown type', () {
      final handled = ErrorHandler.handle(Exception('something broke'));
      expect(handled.type, AppErrorType.unknown);
    });

    test('message returns user-friendly text', () {
      final msg = ErrorHandler.message(Exception('raw technical error'));
      expect(msg, isNotEmpty);
      expect(msg, isNot(contains('raw technical error')));
    });
  });

  group('AppConfig', () {
    test('has development environment', () {
      expect(AppConfig.environment, AppEnvironment.development);
    });

    test('has API base URL', () {
      expect(AppConfig.apiBaseUrl, isNotEmpty);
    });

    test('useMockData is false — backend is live (Phase 2+)', () {
      // useMockData was true in Phase 1 (mock-only).
      // It is false from Phase 2 onwards because the real backend is connected.
      expect(AppConfig.useMockData, isFalse);
    });

    test('feature flags work', () {
      expect(AppConfig.isFeatureEnabled('enable_emergency'), isTrue);
      expect(AppConfig.isFeatureEnabled('nonexistent_feature'), isFalse);
    });
  });
}
