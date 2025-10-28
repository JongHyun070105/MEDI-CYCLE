import 'package:flutter_test/flutter_test.dart';
import 'package:medi_cycle_app/shared/services/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiClient base config', () {
    test('has baseUrl and json header configured', () async {
      final client = ApiClient();
      expect(client.dio.options.baseUrl.isNotEmpty, true);
      expect(client.dio.options.headers['Content-Type'] != null, true);
    });
  });
}
