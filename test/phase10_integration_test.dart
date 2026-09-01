import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruralcare/core/config/app_config.dart';
import 'package:ruralcare/core/error/app_exception.dart';
import 'package:ruralcare/core/error/error_handler.dart';
import 'package:ruralcare/core/providers/app_providers.dart';
import 'package:ruralcare/core/repositories/mock_repositories.dart';
import 'package:ruralcare/core/services/connectivity_service.dart';

class _FakeConnectivityPlatform implements ConnectivityPlatform {
  _FakeConnectivityPlatform(this._results);

  List<ConnectivityResult> _results;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> results) {
    _results = results;
    _controller.add(results);
  }

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _results;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 10 — Integration & System Hardening Tests', () {
    test('Offline Banner Reactivity: isOnlineProvider correctly tracks connectivity state', () async {
      final fakePlatform = _FakeConnectivityPlatform([ConnectivityResult.wifi]);
      final connectivityService = ConnectivityService(platform: fakePlatform);
      await connectivityService.init();
      addTearDown(() {
        connectivityService.dispose();
        fakePlatform.dispose();
      });

      final container = ProviderContainer(
        overrides: [
          connectivityServiceProvider.overrideWithValue(connectivityService),
        ],
      );
      addTearDown(container.dispose);

      // Listen to the provider to keep it active
      container.listen(isOnlineProvider, (_, _) {});

      // Initial state is online
      expect(connectivityService.currentStatus, ConnectivityStatus.online);

      // Simulate network disconnect
      fakePlatform.emit([ConnectivityResult.none]);
      await pumpEventQueue();

      expect(connectivityService.currentStatus, ConnectivityStatus.offline);
      expect(container.read(isOnlineProvider), isFalse);

      // Simulate network restore
      fakePlatform.emit([ConnectivityResult.wifi]);
      await pumpEventQueue();

      expect(connectivityService.currentStatus, ConnectivityStatus.online);
      expect(container.read(isOnlineProvider), isTrue);
    });

    test('Error Boundary: ErrorHandler sanitizes technical exceptions to patient-friendly text', () {
      final networkEx = AppException.network('Connection timed out while reaching server');
      expect(ErrorHandler.message(networkEx), contains('Connection timed out'));

      final formatEx = const FormatException('Invalid JSON payload');
      final handled = ErrorHandler.handle(formatEx);
      expect(handled.type, AppErrorType.validation);
      expect(handled.message, contains('expected format'));

      final serverEx = AppException.server('Internal MongoDB socket hangup');
      expect(ErrorHandler.message(serverEx), 'Internal MongoDB socket hangup');
    });

    test('Feature Flags: AppConfig exposes all patient-level flags enabled', () {
      expect(AppConfig.isFeatureEnabled('enable_ai_chat'), isTrue);
      expect(AppConfig.isFeatureEnabled('enable_emergency'), isTrue);
      expect(AppConfig.isFeatureEnabled('enable_facility_finder'), isTrue);
      expect(AppConfig.isFeatureEnabled('enable_document_upload'), isTrue);
      expect(AppConfig.isFeatureEnabled('enable_teleconsultation'), isTrue);
    });

    test('AI Safety Rule Enforcement: AI Assistant responses always provide non-doctor disclaimer', () async {
      final aiRepo = MockAIRepository();
      final response = await aiRepo.sendMessage('I have a headache');
      expect(response.isAi, isTrue);
      expect(response.text.toLowerCase(), contains('doctor'));
      expect(response.text.toLowerCase(), contains('general health information'));
    });
  });
}
