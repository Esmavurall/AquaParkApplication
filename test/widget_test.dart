// AquaPark uygulaması için temel smoke test.

import 'package:flutter_test/flutter_test.dart';

import 'package:aquapark/main.dart';

void main() {
  testWidgets('Karşılama ekranı açılır', (WidgetTester tester) async {
    await tester.pumpWidget(const AquaParkApp());

    // Karşılama ekranındaki başlık ve buton görünmeli.
    expect(find.textContaining('Aqua'), findsOneWidget);
    expect(find.textContaining('Park'), findsOneWidget);
    expect(find.text('Giriş yaparak devam et'), findsOneWidget);
  });
}
