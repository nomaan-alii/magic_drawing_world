
import 'package:flutter_test/flutter_test.dart';
import 'package:magic_drawing_world/main.dart';

void main() {
  testWidgets('Magic Drawing World opens', (tester) async {
    await tester.pumpWidget(const MagicDrawingWorldApp());

    expect(find.text('Magic'), findsOneWidget);
    expect(find.text('Drawing World'), findsOneWidget);
  });
}
