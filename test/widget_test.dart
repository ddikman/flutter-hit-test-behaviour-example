// Tests for the GestureDetector / HitTestBehavior demo.
//
// The assertions encode the lesson under REAL hit-testing: a gap tap is dead
// under the default behaviour (A → "missed"), live under opaque (B) and the
// transparent fill (D), and live + passing through to the layer behind under
// translucent (C). Misses/pass-throughs are surfaced by a raw Listener catcher
// behind each box, so the events are genuine, not simulated.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter_hit_test_behaviour_example/main.dart';

void main() {
  // Use bundled/fallback fonts in tests instead of fetching from the network.
  GoogleFonts.config.allowRuntimeFetching = false;

  // A wide, tall surface so all four cards render in one row, fully on-screen.
  Future<void> pumpDemo(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const HitTestDemoApp());
    await tester.pump();
  }

  // Disposing the tree cancels the periodic timer, flash timers and the pulse
  // controller, avoiding pending timer/ticker failures at teardown.
  Future<void> disposeTree(WidgetTester tester) => tester.pumpWidget(const SizedBox());

  // A point inside a box's outline but above the centered letter — the gap.
  Offset gapOf(WidgetTester tester, String id) =>
      tester.getRect(find.byKey(Key('box-$id'))).topCenter + const Offset(0, 14);

  testWidgets('renders the four boxes and the waiting status', (tester) async {
    await pumpDemo(tester);

    expect(find.text('GestureDetector & HitTestBehavior'), findsOneWidget);
    expect(find.text('Waiting for a tap'), findsOneWidget);
    for (final id in ['A', 'B', 'C', 'D']) {
      expect(find.byKey(Key('box-$id')), findsOneWidget);
    }

    await disposeTree(tester);
  });

  testWidgets('A: tapping the letter registers', (tester) async {
    await pumpDemo(tester);

    await tester.tap(find.byKey(const Key('label-A')));
    await tester.pump();

    expect(find.textContaining('Box A'), findsOneWidget);
    expect(find.textContaining('letter tap registered'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('A: tapping the empty gap misses (deferToChild dead zone)', (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, 'A'));
    await tester.pump();

    expect(find.textContaining('Box A'), findsOneWidget);
    expect(find.textContaining('empty gap tap missed'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('B: tapping the empty gap registers (opaque)', (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, 'B'));
    await tester.pump();

    expect(find.textContaining('Box B'), findsOneWidget);
    expect(find.textContaining('empty gap tap registered'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('C: gap tap registers and passes through to the layer behind', (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, 'C'));
    await tester.pump();

    expect(find.textContaining('Box C'), findsOneWidget);
    expect(find.textContaining('passed through'), findsOneWidget);

    await disposeTree(tester);
  });

  testWidgets('D: gap tap registers via the transparent fill', (tester) async {
    await pumpDemo(tester);

    await tester.tapAt(gapOf(tester, 'D'));
    await tester.pump();

    expect(find.textContaining('Box D'), findsOneWidget);
    expect(find.textContaining('empty gap tap registered'), findsOneWidget);

    await disposeTree(tester);
  });
}
