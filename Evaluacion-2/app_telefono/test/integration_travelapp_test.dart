import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_telefono/main.dart';
import 'package:app_telefono/models/pasajero.dart';
import 'package:app_telefono/services/ble_simulation_service.dart';
import 'package:app_telefono/utils/travel_whitebox_logic.dart';

void main() {
  group('AUT-04 a AUT-06: Pruebas de Integracion TravelApp', () {
    testWidgets('Integracion 1 (UI + Validacion) - LoginScreen rechaza campos vacios y contrasena corta', (WidgetTester tester) async {
      await tester.pumpWidget(const TravelAppMobile());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pump();
      expect(find.text('Debes ingresar tus credenciales.'), findsOneWidget);

      ScaffoldMessenger.of(tester.element(find.byType(Scaffold))).clearSnackBars();
      await tester.pump();

      await tester.enterText(find.byType(TextField).at(0), 'usuario@travelapp.com');
      await tester.enterText(find.byType(TextField).at(1), '12345');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Ingresar'));
      await tester.pump();
      expect(find.text('Credenciales inválidas.'), findsOneWidget);
    });

    test('Integracion 2 (Servicio + HTTP 200 + Stream) - BleSimulationService consume y emite telemetria', () async {
      final service = BleSimulationService();
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/wearable/data');
        expect(request.method, 'GET');
        return http.Response(
          jsonEncode({'heartRate': 84, 'steps': 1250, 'calories': 92}),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final directData = await service.obtenerDatosWearable(client: mockClient);
      expect(directData['heartRate'], 84);
      expect(directData['steps'], 1250);

      final nextEmission = service.sensorDataStream.first;
      service.startListening(client: mockClient);
      final streamedData = await nextEmission.timeout(const Duration(seconds: 3));
      expect(streamedData['calories'], 92);

      service.stopListening();
    });

    test('Integracion 3 (Servicio + Resiliencia) - Manejo de HTTP 500 y servidor sin respuesta', () async {
      final service = BleSimulationService();

      final serverErrorClient = MockClient((_) async => http.Response('Internal Server Error', 500));
      await expectLater(
        () => service.obtenerDatosWearable(client: serverErrorClient),
        throwsA(isA<Exception>()),
      );

      final timeoutClient = MockClient((_) async => throw TimeoutException('Servidor no responde'));
      await expectLater(
        () => service.obtenerDatosWearable(client: timeoutClient),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('Integracion 4 (Logica + Persistencia) - Registro, lectura y actualizacion persistente de Pasajero', () async {
      final tempDir = await Directory.systemTemp.createTemp('travelapp_p13_');
      final storageFile = File('${tempDir.path}/pasajeros_store.json');

      try {
        final procesado = TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Ana Lopez',
          edadTexto: '29',
          tipo: 'Turista',
          correo: 'ana@travelapp.com',
          tarifaBase: 1800,
        );

        final nuevo = Pasajero(
          id: 1,
          nombre: procesado['nombre'],
          edad: procesado['edad'],
          tipo: procesado['tipo'],
          correo: procesado['correo'],
        );

        await storageFile.writeAsString(jsonEncode([nuevo.toMap()]));

        final rawRead = jsonDecode(await storageFile.readAsString()) as List<dynamic>;
        final cargados = rawRead
            .map((item) => Pasajero.fromMap(Map<String, dynamic>.from(item)))
            .toList();

        expect(cargados.length, 1);
        expect(cargados.first.nombre, 'Ana Lopez');
        expect(cargados.first.tipo, 'TURISTA');

        final actualizado = Pasajero(
          id: cargados.first.id,
          nombre: cargados.first.nombre,
          edad: cargados.first.edad,
          tipo: 'VIP',
          correo: cargados.first.correo,
        );
        await storageFile.writeAsString(jsonEncode([actualizado.toMap()]));

        final rawAfterUpdate = jsonDecode(await storageFile.readAsString()) as List<dynamic>;
        final recargado = Pasajero.fromMap(Map<String, dynamic>.from(rawAfterUpdate.first));
        expect(recargado.id, 1);
        expect(recargado.tipo, 'VIP');
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
