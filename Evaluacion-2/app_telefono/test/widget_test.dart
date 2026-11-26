import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:app_telefono/main.dart';

void main() {
  testWidgets('TravelAppMobile renderiza LoginScreen correctamente', (WidgetTester tester) async {
    await tester.pumpWidget(const TravelAppMobile());

    expect(find.text('Acceso Seguro'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Ingresar'), findsOneWidget);
  });
}
