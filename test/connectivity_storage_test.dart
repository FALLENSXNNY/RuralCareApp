// Unit tests for connectivity service
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/services/connectivity_service.dart';

class _FakeConnectivityPlatform implements ConnectivityPlatform {
  _FakeConnectivityPlatform(this._results);

  final List<ConnectivityResult> _results;
  final StreamController<List<ConnectivityResult>> _controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  void emit(List<ConnectivityResult> results) {
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

  group('ConnectivityService', () {
    test('initial status is online', () {
      final fake = _FakeConnectivityPlatform([ConnectivityResult.wifi]);
      final service = ConnectivityService(platform: fake);
      expect(service.currentStatus, ConnectivityStatus.online);
      service.dispose();
      fake.dispose();
    });

    test('checkNow returns online status when connected', () async {
      final fake = _FakeConnectivityPlatform([ConnectivityResult.wifi]);
      final service = ConnectivityService(platform: fake);
      final status = await service.checkNow();
      expect(status, ConnectivityStatus.online);
      service.dispose();
      fake.dispose();
    });

    test('checkNow returns offline status when disconnected', () async {
      final fake = _FakeConnectivityPlatform([ConnectivityResult.none]);
      final service = ConnectivityService(platform: fake);
      final status = await service.checkNow();
      expect(status, ConnectivityStatus.offline);
      service.dispose();
      fake.dispose();
    });

    test('statusStream is a broadcast stream', () {
      final fake = _FakeConnectivityPlatform([ConnectivityResult.wifi]);
      final service = ConnectivityService(platform: fake);
      expect(service.statusStream.isBroadcast, isTrue);
      service.dispose();
      fake.dispose();
    });

    test('reacts to connectivity changes', () async {
      final fake = _FakeConnectivityPlatform([ConnectivityResult.wifi]);
      final service = ConnectivityService(platform: fake);
      await service.init();

      final statuses = <ConnectivityStatus>[];
      final subscription = service.statusStream.listen(statuses.add);

      // Simulate going offline
      fake.emit([ConnectivityResult.none]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Simulate coming back online
      fake.emit([ConnectivityResult.mobile]);
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(statuses, contains(ConnectivityStatus.offline));
      expect(statuses, contains(ConnectivityStatus.online));

      await subscription.cancel();
      service.dispose();
      fake.dispose();
    });
  });
}
