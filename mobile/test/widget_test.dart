import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/app/app.dart';

void main() {
  testWidgets('InstaPET app smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: InstaPetApp()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
