import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';

void main() {
  testWidgets('CareLink App loads AI Health Assistant', (WidgetTester tester) async {
    await tester.pumpWidget(const CareLinkApp());
    expect(find.text('AI Health Assistant'), findsOneWidget);
  });
}
