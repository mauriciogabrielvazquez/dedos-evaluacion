import 'package:flutter_test/flutter_test.dart';
import 'package:app_telefono/utils/travel_whitebox_logic.dart';
import 'package:app_telefono/models/pasajero.dart';

void main() {
  group('AUT-01 a AUT-03: Pruebas Unitarias TravelApp', () {
    test('Unitaria 1 - Entrada valida en credenciales de login', () {
      final res = TravelWhiteboxLogic.validarCredencialesLogin(
        'mauricio@travelapp.com',
        'Segura2026',
      );
      expect(res, 'VALIDO');
    });

    test('Unitaria 2 - Entrada vacia o solo espacios en login y pasajero', () {
      expect(TravelWhiteboxLogic.validarCredencialesLogin('', 'Segura2026'), 'VACIO');
      expect(TravelWhiteboxLogic.validarCredencialesLogin('   ', '   '), 'VACIO');
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: '   ',
          edadTexto: '23',
          tipo: 'Turista',
          correo: 'a@b.com',
          tarifaBase: 1200,
        ),
        throwsArgumentError,
      );
    });

    test('Unitaria 3 - Valores fuera de rango (longitud, edad y tarifa)', () {
      expect(
        TravelWhiteboxLogic.validarCredencialesLogin('a' * 51, 'Segura2026'),
        'EXCESO_LONGITUD',
      );
      expect(
        TravelWhiteboxLogic.validarCredencialesLogin('user@mail.com', '1234567'),
        'PASSWORD_CORTA',
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Carlos',
          edadTexto: '-5',
          tipo: 'Turista',
          correo: 'c@mail.com',
          tarifaBase: 1000,
        ),
        throwsRangeError,
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Carlos',
          edadTexto: '125',
          tipo: 'Turista',
          correo: 'c@mail.com',
          tarifaBase: 1000,
        ),
        throwsRangeError,
      );
    });

    test('Unitaria 4 - Resultado esperado de tarifas y descuentos por categoria', () {
      final menor = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Mateo',
        edadTexto: '8',
        tipo: '',
        correo: 'mateo@mail.com',
        tarifaBase: 2000,
      );
      expect(menor['categoria'], 'MENOR');
      expect(menor['tipo'], 'TURISTA');
      expect(menor['tarifaFinal'], 1000.0);

      final vip = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Sofia',
        edadTexto: '28',
        tipo: 'vip',
        correo: 'sofia@mail.com',
        tarifaBase: 2000,
      );
      expect(vip['categoria'], 'VIP');
      expect(vip['tarifaFinal'], 1600.0);

      final mayor = TravelWhiteboxLogic.procesarPasajeroYTarifa(
        nombre: 'Elena',
        edadTexto: '65',
        tipo: 'Frecuente',
        correo: 'elena@mail.com',
        tarifaBase: 2000,
      );
      expect(mayor['categoria'], 'ADULTO_MAYOR');
      expect(mayor['tarifaFinal'], 1400.0);
    });

    test('Unitaria 5 - Manejo de excepciones con edad no numerica y tarifa cero', () {
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Luis',
          edadTexto: 'veintitres',
          tipo: 'Turista',
          correo: 'luis@mail.com',
          tarifaBase: 1500,
        ),
        throwsFormatException,
      );
      expect(
        () => TravelWhiteboxLogic.procesarPasajeroYTarifa(
          nombre: 'Luis',
          edadTexto: '23',
          tipo: 'Turista',
          correo: 'luis@mail.com',
          tarifaBase: 0,
        ),
        throwsArgumentError,
      );
    });

    test('Unitaria 6 - Formato de correo invalido en login', () {
      expect(
        TravelWhiteboxLogic.validarCredencialesLogin('correo_sin_arroba.com', 'Segura2026'),
        'EMAIL_INVALIDO',
      );
      expect(
        TravelWhiteboxLogic.validarCredencialesLogin('correo@sindominio', 'Segura2026'),
        'EMAIL_INVALIDO',
      );
    });

    test('Unitaria 7 - Serializacion y deserializacion del modelo Pasajero', () {
      final original = Pasajero(
        id: 10,
        nombre: 'Mauricio Vazquez',
        edad: 23,
        tipo: 'VIP',
        correo: 'mauricio@uteq.edu.mx',
      );
      final mapa = original.toMap();
      final reconstruido = Pasajero.fromMap(mapa);

      expect(reconstruido.id, 10);
      expect(reconstruido.nombre, 'Mauricio Vazquez');
      expect(reconstruido.edad, 23);
      expect(reconstruido.tipo, 'VIP');
      expect(reconstruido.correo, 'mauricio@uteq.edu.mx');
    });
  });
}
