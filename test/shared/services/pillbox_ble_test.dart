import 'package:flutter_test/flutter_test.dart';
import 'package:medi_cycle_app/shared/services/pillbox_ble.dart';

void main() {
  group('Pillbox BLE skeleton', () {
    test('scan yields at least one device (mock)', () async {
      final devices = await pillboxBle.scan().take(1).toList();
      expect(devices.isNotEmpty, true);
    });

    test('connect/disconnect does not throw (mock)', () async {
      final dev = (await pillboxBle.scan().take(1).toList()).first;
      await pillboxBle.connect(dev.id);
      await pillboxBle.disconnect();
    });
  });
}
