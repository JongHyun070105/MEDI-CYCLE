// BLE skeleton for smart pillbox integration
// Define minimal interfaces for scanning/connection/characteristics.

class BleDeviceSummary {
  final String id;
  final String name;
  BleDeviceSummary({required this.id, required this.name});
}

abstract class PillboxBle {
  Stream<BleDeviceSummary> scan();
  Future<void> stopScan();
  Future<void> connect(String deviceId);
  Future<void> disconnect();

  // Characteristics (skeleton)
  Stream<bool> onMedicationDetected();
  Stream<int> onBatteryLevel();
  Future<void> setLock(bool lock);
}

/// Mock implementation until real BLE plugin is wired
class MockPillboxBle implements PillboxBle {
  bool _connected = false;

  @override
  Stream<BleDeviceSummary> scan() async* {
    yield BleDeviceSummary(id: 'MOCK-001', name: 'Pillbox-Dev');
  }

  @override
  Future<void> stopScan() async {}

  @override
  Future<void> connect(String deviceId) async {
    _connected = true;
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
  }

  @override
  Stream<bool> onMedicationDetected() async* {
    if (!_connected) return;
    yield true;
  }

  @override
  Stream<int> onBatteryLevel() async* {
    if (!_connected) return;
    yield 85;
  }

  @override
  Future<void> setLock(bool lock) async {}
}

final PillboxBle pillboxBle = MockPillboxBle();
