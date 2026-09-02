import 'package:flutter_test/flutter_test.dart';
import 'package:app_bora_trampar/bora_trampar_app.dart';

void main() {
  testWidgets('App renders WelcomeScreen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BoraTrampaApp());
    expect(find.text('Sou cliente'), findsOneWidget);
    expect(find.text('Sou profissional'), findsOneWidget);
  });
}
