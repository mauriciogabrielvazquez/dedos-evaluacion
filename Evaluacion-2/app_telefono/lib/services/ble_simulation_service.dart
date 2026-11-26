import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BleSimulationService {
  static const String baseUrl = 'http://192.168.0.107:3000/api';

  final _sensorDataController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get sensorDataStream =>
      _sensorDataController.stream;

  Timer? _pollingTimer;

  Future<Map<String, dynamic>> obtenerDatosWearable({http.Client? client}) async {
    final httpClient = client ?? http.Client();
    try {
      final response = await httpClient
          .get(Uri.parse('$baseUrl/wearable/data'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        throw Exception('Error HTTP ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || !decoded.containsKey('heartRate')) {
        throw const FormatException('Estructura JSON de wearable invalida');
      }

      return decoded;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  void startListening({http.Client? client}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        final data = await obtenerDatosWearable(client: client);
        if (!_sensorDataController.isClosed) {
          _sensorDataController.add(data);
        }
      } catch (_) {}
    });
  }

  void stopListening() {
    _pollingTimer?.cancel();
    _sensorDataController.close();
  }
}
