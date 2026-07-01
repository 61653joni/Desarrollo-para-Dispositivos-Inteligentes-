import 'package:flutter_test/flutter_test.dart';

import 'package:wearable_app/main.dart';

void main() {
  testWidgets('WearableApp muestra pantalla inicial con boton Iniciar',
      (WidgetTester tester) async {
    await tester.pumpWidget(const WearableApp());

    expect(find.text('72'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);
  });
}
