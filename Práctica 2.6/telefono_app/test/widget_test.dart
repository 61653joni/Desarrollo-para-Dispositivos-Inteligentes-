import 'package:flutter_test/flutter_test.dart';

import 'package:telefono_app/main.dart';

void main() {
  testWidgets('TelefonoApp muestra pantalla para conectar wearable',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TelefonoApp());

    expect(find.text('Conecta tu wearable'), findsOneWidget);
    expect(find.text('Buscar wearable'), findsOneWidget);
  });
}
