import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const HitTestDemoApp());
}

class HitTestDemoApp extends StatelessWidget {
  const HitTestDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureDetector HitTestBehavior',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  /// Label of the most recently tapped button (A/B/C/D), or null before any tap.
  String? _lastLabel;

  /// When the most recent tap happened — used to render "N seconds ago".
  DateTime? _lastTapTime;

  /// Whether the raw [Listener] behind button C received the last tap. This is
  /// what makes `translucent`'s pass-through visible.
  bool _behindCActive = false;

  /// Re-renders once a second so the "N seconds ago" text keeps counting up.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _handleTap(String label) {
    setState(() {
      _lastLabel = label;
      _lastTapTime = DateTime.now();
      // Reset the "behind C" indicator whenever a different button is tapped.
      if (label != 'C') _behindCActive = false;
    });
  }

  void _markBehindC() {
    setState(() => _behindCActive = true);
  }

  String _statusText() {
    final label = _lastLabel;
    final tapTime = _lastTapTime;
    if (label == null || tapTime == null) {
      return 'No button tapped yet';
    }
    final seconds = DateTime.now().difference(tapTime).inSeconds;
    final ago = seconds <= 0
        ? 'just now'
        : '$seconds second${seconds == 1 ? '' : 's'} ago';
    final base = 'Button $label tapped $ago';
    if (label == 'C' && _behindCActive) {
      return '$base  ·  the layer behind it also received the tap';
    }
    return base;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('GestureDetector HitTestBehavior'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'GestureDetector & HitTestBehavior',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Each box below is a GestureDetector wrapping a centered label, '
                  'with a rounded outline and generous padding so there is an empty '
                  'gap between the label and the border. Tap the label, then tap the '
                  'empty gap inside the outline, and watch the status line to see '
                  'which taps actually register.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                _DemoButton(
                  boxKey: const Key('box-A'),
                  label: 'A',
                  caption:
                      'Default (deferToChild) — the GestureDetector wraps only the '
                      'label, so taps in the empty gap do nothing.',
                  onTap: () => _handleTap('A'),
                  // behavior left null => the framework default, deferToChild.
                ),
                const SizedBox(height: 16),
                _DemoButton(
                  boxKey: const Key('box-B'),
                  label: 'B',
                  caption: 'HitTestBehavior.opaque — the whole box is tappable, '
                      'gap included.',
                  onTap: () => _handleTap('B'),
                  behavior: HitTestBehavior.opaque,
                ),
                const SizedBox(height: 16),
                _buildTranslucentDemo(context),
                const SizedBox(height: 16),
                _DemoButton(
                  boxKey: const Key('box-D'),
                  label: 'D',
                  caption:
                      'Default behaviour, but the label sits on a Colors.transparent '
                      'fill (ColoredBox), which hit-tests across the whole box — so '
                      'the gap taps. Looks identical to A.',
                  onTap: () => _handleTap('D'),
                  transparentFill: true,
                ),
                const SizedBox(height: 24),
                Text(
                  'Tip: aim for the empty space inside the outline, not the letter.',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText(),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'By default a GestureDetector only fires where one of its children '
                  'is actually hit, so empty padding around a label is dead. Set '
                  'behavior: HitTestBehavior.opaque to make the whole box a tap '
                  'target (it also blocks widgets behind it). A Colors.transparent '
                  'fill works too, but it is an implicit side effect — prefer opaque, '
                  'or a Material button, for real tap targets. (Note: a bordered '
                  'BoxDecoration already fills its hit area, so a literal outlined '
                  'Container would be tappable everywhere by default — that is why '
                  'the outline here is drawn separately from the tap target.)',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Button C: a `translucent` GestureDetector stacked over a raw pointer
  /// [Listener]. Tapping the empty gap fires C's `onTap` *and* lets the pointer
  /// pass through to the layer behind (which highlights). With `opaque` the
  /// layer behind would be blocked.
  ///
  /// Two details matter here:
  ///  * The layer behind is a raw [Listener], not a second [GestureDetector]:
  ///    the gesture arena resolves a tap to a single winner, so a competing
  ///    `onTap` behind would never fire — but a raw `onPointerDown` is not in
  ///    the arena and reliably shows the pass-through.
  ///  * The outline is wrapped in [IgnorePointer] so it cannot absorb the tap
  ///    before it reaches the layer behind (a bordered BoxDecoration hit-tests
  ///    across its whole area).
  Widget _buildTranslucentDemo(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: const Key('box-C'),
          height: 120,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1) The layer BEHIND — a raw pointer listener.
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: (_) => _markBehindC(),
                child: ColoredBox(
                  color: _behindCActive
                      ? theme.colorScheme.tertiaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              // 2) The outline — painted but excluded from hit testing.
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: theme.colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              // 3) The translucent GestureDetector on top.
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => _handleTap('C'),
                child: Center(
                  child: Text('C', style: theme.textTheme.displaySmall),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'HitTestBehavior.translucent — the whole box is tappable, and a tap in '
          'the empty gap also passes through to the layer behind it (which '
          'highlights). opaque would have blocked that layer.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({
    required this.boxKey,
    required this.label,
    required this.caption,
    required this.onTap,
    this.behavior,
    this.transparentFill = false,
  });

  final Key boxKey;
  final String label;
  final String caption;
  final VoidCallback onTap;

  /// The HitTestBehavior under test. `null` reproduces the framework default
  /// (deferToChild), so button A behaves as an untouched GestureDetector.
  final HitTestBehavior? behavior;

  /// When true, wraps the label in a `Colors.transparent` ColoredBox so the
  /// whole box becomes hit-testable even under the default behaviour (button D).
  final bool transparentFill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget content = Center(
      child: Text(label, style: theme.textTheme.displaySmall),
    );
    if (transparentFill) {
      content = ColoredBox(color: Colors.transparent, child: content);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          key: boxKey,
          height: 120,
          // The outline is drawn by this parent DecoratedBox, so it is NOT part
          // of the GestureDetector's hit-tested child subtree. Only the label
          // (or the transparent fill) can register a hit.
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: GestureDetector(
              behavior: behavior,
              onTap: onTap,
              child: content,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(caption, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
