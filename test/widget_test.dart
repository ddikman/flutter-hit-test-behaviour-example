// Tests for the GestureDetector / HitTestBehavior demo.
//
// The key assertions encode the lesson itself: tapping the empty gap is dead
// under the default behaviour (A), live under opaque (B) and the transparent
// fill (D), and live + passing through to the layer behind under translucent (C).

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_hit_test_behaviour_example/main.dart';

void main() {
  // Give the test a tall surface so all four buttons sit on-screen. Otherwise
  // the lower buttons fall below the default 600px viewport and tapAt() at
  // their (off-screen) positions hits the scroll view's clip, not the button.
  Future<void> pumpDemo(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const HitTestDemoApp());
  }

  // Disposing the tree cancels the periodic Timer started in initState,
  // avoiding a "Timer is still pending" failure at test teardown.
  Future<void> disposeTree(WidgetTester tester) =>
      tester.pumpWidget(const SizedBox());

  // A point inside the outline but clearly above the centered letter — i.e. in
  // the empty gap, away from the rounded corners.
  Offset gapOf(WidgetTester tester, Key key) =>
      tester.getRect(find.byKey(key)).topCenter + const Offset(0, 14);

  testWidgets('renders all four buttons and the initial status',
      (tester) async {
    await pumpDemo(tester);

    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('No button tapped yet'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('A: tapping the label registers', (tester) async {
    await pumpDemo(tester);

    await tester.tap(find.text('A'));
    await tester.pump();

    expect(find.textContaining('Button A tapped'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('A: tapping the empty gap does NOT register (deferToChild)',
      (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, const Key('box-A')));
    await tester.pump();

    // No tap registered, so the status is still the initial text.
    expect(find.text('No button tapped yet'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('B: tapping the empty gap DOES register (opaque)', (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, const Key('box-B')));
    await tester.pump();

    expect(find.textContaining('Button B tapped'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('D: tapping the empty gap registers via the transparent fill',
      (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, const Key('box-D')));
    await tester.pump();

    expect(find.textContaining('Button D tapped'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('C: gap tap registers AND passes through to the layer behind',
      (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, const Key('box-C')));
    await tester.pump();

    expect(find.textContaining('Button C tapped'), findsOneWidget);
    expect(find.textContaining('also received the tap'), findsOneWidget);

    await disposeTree(tester);
  });
}
