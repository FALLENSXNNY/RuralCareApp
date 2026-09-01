// Connectivity service — real-time online/offline detection using connectivity_plus
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectivityStatus { online, offline }

/// Abstraction over the connectivity plugin so the service can be tested
/// with a fake implementation.
abstract class ConnectivityPlatform {
  Future<List<ConnectivityResult>> checkConnectivity();
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

/// Default implementation backed by the connectivity_plus plugin.
class PluginConnectivityPlatform implements ConnectivityPlatform {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      _connectivity.checkConnectivity();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}

class ConnectivityService {
  ConnectivityService({ConnectivityPlatform? platform})
    : _platform = platform ?? PluginConnectivityPlatform() {
    init();
  }

  final ConnectivityPlatform _platform;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  ConnectivityStatus _currentStatus = ConnectivityStatus.online;

  /// Current connectivity status.
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Stream of connectivity status changes.
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Initializes the service and starts listening for connectivity changes.
  Future<void> init() async {
    try {
      // Check initial status
      final results = await _platform.checkConnectivity();
      _updateStatus(results);
    } catch (_) {}

    // Listen for changes
    _subscription?.cancel();
    _subscription = _platform.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final isOnline = results.isNotEmpty &&
        results.any((r) => r != ConnectivityResult.none);
    final newStatus = isOnline
        ? ConnectivityStatus.online
        : ConnectivityStatus.offline;

    _currentStatus = newStatus;
    if (!_statusController.isClosed) {
      _statusController.add(newStatus);
    }
  }

  /// Checks connectivity once and returns the current status.
  Future<ConnectivityStatus> checkNow() async {
    final results = await _platform.checkConnectivity();
    _updateStatus(results);
    return _currentStatus;
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
