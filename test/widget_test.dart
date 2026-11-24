// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daftarche/main.dart';

void main() {
  setUpAll(() {
    dotenv.loadFromString(
      envString: 'UPUPA_BASE_URL=http://127.0.0.1:8090\n',
      isOptional: true,
    );
  });

  testWidgets('DaftarcheApp renders main screen and search field', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DaftarcheApp());
    await tester.pump();

    expect(find.text('دفترچه'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
