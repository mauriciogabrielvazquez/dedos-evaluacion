class TravelWhiteboxLogic {
  /// MÉTODO CRÍTICO 1 (Validación): Reglas de seguridad de LoginScreen
  static String validarCredencialesLogin(String email, String password) {
    final cleanEmail = email.trim();
    final cleanPass = password.trim();

    if (cleanEmail.isEmpty || cleanPass.isEmpty) {
      return 'VACIO';
    }
    if (email.length > 50 || password.length > 50) {
      return 'EXCESO_LONGITUD';
    }
    if (password.length < 8) {
      return 'PASSWORD_CORTA';
    }
    if (!cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return 'EMAIL_INVALIDO';
    }
    return 'VALIDO';
  }

  /// MÉTODO CRÍTICO 2 (Procesamiento / Cálculo): Procesa datos de Pasajero y calcula tarifa
  static Map<String, dynamic> procesarPasajeroYTarifa({
    required String nombre,
    required String edadTexto,
    required String tipo,
    required String correo,
    required double tarifaBase,
  }) {
    if (nombre.trim().isEmpty) {
      throw ArgumentError('El nombre es obligatorio');
    }
    if (tarifaBase <= 0) {
      throw ArgumentError('La tarifa base debe ser mayor a cero');
    }

    final edad = int.tryParse(edadTexto.trim());
    if (edad == null) {
      throw const FormatException('La edad debe ser un número entero');
    }
    if (edad < 0 || edad > 120) {
      throw RangeError.range(edad, 0, 120, 'edad');
    }

    final tipoNormalizado = tipo.trim().toUpperCase();
    double descuento = 0.0;
    String categoria = 'ADULTO';

    if (edad < 12) {
      descuento = 0.50;
      categoria = 'MENOR';
    } else if (edad >= 60) {
      descuento = 0.30;
      categoria = 'ADULTO_MAYOR';
    } else if (tipoNormalizado == 'VIP') {
      descuento = 0.20;
      categoria = 'VIP';
    }

    final tarifaFinal = double.parse((tarifaBase * (1 - descuento)).toStringAsFixed(2));

    return {
      'nombre': nombre.trim(),
      'edad': edad,
      'tipo': tipoNormalizado.isEmpty ? 'TURISTA' : tipoNormalizado,
      'correo': correo.trim(),
      'categoria': categoria,
      'descuento': descuento,
      'tarifaFinal': tarifaFinal,
    };
  }
}