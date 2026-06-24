import 'package:flutter/material.dart';
import 'package:flutter_hit_test_behaviour_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('multi-column grid renders pseudocode without overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1320, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const HitTestDemoApp());
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.textContaining('GestureDetector(opaque)'), findsOneWidget);
    expect(find.textContaining('ColoredBox(transparent)'), findsOneWidget);
  });
}
