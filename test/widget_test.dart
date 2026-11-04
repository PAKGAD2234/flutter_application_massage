import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_massage/main.dart';
import 'package:flutter_application_massage/view/splash_ui.dart';

void main() {
  testWidgets('shows massage booking home page', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(SplashUi), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox());
  });
}
