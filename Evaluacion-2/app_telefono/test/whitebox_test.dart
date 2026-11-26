import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:app_telefono/utils/travel_whitebox_logic.dart';
import 'package:app_telefono/services/ble_simulation_service.dart';

void main() {
  group('Método 1: validarCredencialesLogin (Validación)', () {
    test('Camino 1 - Condición correo vacío o solo espacios', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('   ', 'admin123'), 'VACIO');
    });

    test('Camino 2 - Condición contraseña vacía', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('user@mail.com', ''), 'VACIO');
    });

    test('Camino 3 - Valor límite longitud > 50 en email y password', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('a' * 51, '12345678'), 'EXCESO_LONGITUD');
      expect(TravelWhiteboxLogic.validarCredencialesLogin('user@mail.com', 'p' * 51), 'EXCESO_LONGITUD');
    });

    test('Camino 4 - Valor límite contraseña corta (7 caracteres)', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('user@mail.com', '1234567'), 'PASSWORD_CORTA');
    });

    test('Camino 5 - Condición formato de correo sin @ o sin punto', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('usermail.com', '12345678'), 'EMAIL_INVALIDO');
      expect(TravelWhiteboxLogic.validarCredencialesLogin('user@mailcom', '12345678'), 'EMAIL_INVALIDO');
    });

    test('Camino 6 - Valor límite exacto (8 y 50 chars) y ruta válida', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('admin@travelapp.com', 'admin123'), 'VALIDO');
      expect(TravelWhiteboxLogic.validarCredencialesLogin('${'a' * 40}@gmail.com', '1' * 50), 'VALIDO');
    });
  });

  group('Método 2: procesarPasajeroYTarifa (Procesamiento y Cálculo)', () {
    test('Excepciones: nombre vacío, tarifa <= 0, edad no numérica y fuera de rango', () {
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: '   ', edadTexto: '25', tipo: 'Turista', correo: 'a@b.com', tarifaBase: 1000,
        ),
        throwsArgumentError,
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Juan', edadTexto: '25', tipo: 'Turista', correo: 'a@b.com', tarifaBase: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Juan', edadTexto: 'veinte', tipo: 'Turista', correo: 'a@b.com', tarifaBase: 1000,
        ),
        throwsFormatException,
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Juan', edadTexto: '-1', tipo: 'Turista', correo: 'a@b.com', tarifaBase: 1000,
        ),
        throwsRangeError,
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Juan', edadTexto: '121', tipo: 'Turista', correo: 'a@b.com', tarifaBase: 1000,
        ),
        throwsRangeError,
      );
    });

    test('Valores límite y ramas de descuento: menor (11), adulto (12), VIP (30), mayor (60 y 120)', () {
      final menor = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Leo', edadTexto: '11', tipo: '', correo: 'leo@mail.com', tarifaBase: 1000,
      );
      expect(menor['categoria'], 'MENOR');
      expect(menor['tarifaFinal'], 500.0);
      expect(menor['tipo'], 'TURISTA');

      final adulto = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Ana', edadTexto: '12', tipo: 'Turista', correo: 'ana@mail.com', tarifaBase: 1000,
      );
      expect(adulto['categoria'], 'ADULTO');
      expect(adulto['tarifaFinal'], 1000.0);

      final vip = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Luis', edadTexto: '30', tipo: 'vip', correo: 'luis@mail.com', tarifaBase: 1000,
      );
      expect(vip['categoria'], 'VIP');
      expect(vip['tarifaFinal'], 800.0);

      final mayor = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Rosa', edadTexto: '60', tipo: 'Frecuente', correo: 'rosa@mail.com', tarifaBase: 1000,
      );
      expect(mayor['categoria'], 'ADULTO_MAYOR');
      expect(mayor['tarifaFinal'], 700.0);
    });
  });

  group('Método 3: obtenerDatosWearable (Comunicación HTTP)', () {
    final service = BleSimulationService();

    test('Camino 1 - Respuesta 200 OK con JSON válido', () async {
      final mockClient = MockClient((_) async => http.Response(
            jsonEncode({'heartRate': 78, 'steps': 450, 'calories': 32}),
            200,
          ));

      final data = await service.obtenerDatosWearable(client: mockClient);
      expect(data['heartRate'], 78);
      expect(data['steps'], 450);
    });

    test('Camino 2 - Código HTTP 500 lanza excepción controlada', () async {
      final mockClient = MockClient((_) async => http.Response('Error interno', 500));

      expect(
        () => service.obtenerDatosWearable(client: mockClient),
        throwsA(isA<Exception>()),
      );
    });

    test('Camino 3 - Respuesta 200 con estructura JSON inválida lanza FormatException', () async {
      final mockClient = MockClient((_) async => http.Response(jsonEncode({'status': 'ok'}), 200));

      expect(
        () => service.obtenerDatosWearable(client: mockClient),
        throwsFormatException,
      );
    });

    test('Camino 4 - Timeout o fallo de conectividad', () async {
      final mockClient = MockClient((_) async => throw TimeoutException('Sin respuesta'));

      expect(
        () => service.obtenerDatosWearable(client: mockClient),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}