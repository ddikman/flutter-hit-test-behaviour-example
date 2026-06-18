import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Design tokens (from the imported "HitTestBehavior Demo" Claude Design) ──
const _bg = Color(0xFFFAFAFA);
const _accent = Color(0xFFEC3C1C);
const _accentTint = Color(0xFFFFE9E6);
const _miss = Color(0xFFD93416);
const _ink = Color(0xFF1A1A1A);
const _ink2 = Color(0xFF302E34);
const _body = Color(0xFF696969);
const _sub = Color(0xFF8F8F8F);
const _descColor = Color(0xFF787878);
const _cardBorder = Color(0xFFEFEFEF);
const _boxBorder = Color(0xFFE2E2E2);
const _tagBg = Color(0xFFF4F4F4);
const _tagBorder = Color(0xFFEAEAEA);
const _statusBorder = Color(0xFFE7E7E7);
const _behindColor = Color(0xFFD2DCB5);
const _cardShadow = Color.fromRGBO(20, 18, 24, 0.05);

/// The GitHub repository for this demo, linked from the footer.
final Uri _repoUrl =
    Uri.parse('https://github.com/ddikman/flutter-hit-test-behaviour-example');

TextStyle _inter(double size, FontWeight w, Color c, {double? height, double? spacing}) =>
    GoogleFonts.inter(fontSize: size, fontWeight: w, color: c, height: height, letterSpacing: spacing);

TextStyle _mono(double size, FontWeight w, Color c, {double? spacing}) =>
    GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, color: c, letterSpacing: spacing);

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
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: _bg),
      home: const DemoPage(),
    );
  }
}

enum _Outcome { registered, missed }

class _BoxSpec {
  const _BoxSpec({
    required this.id,
    required this.tag,
    required this.desc,
    required this.gapRegisters,
    this.behavior,
    this.transparentFill = false,
    this.translucent = false,
  });

  final String id; // also the letter shown
  final String tag;
  final String desc;
  final bool gapRegisters; // does a gap tap register on the demo detector?
  final HitTestBehavior? behavior; // null => GestureDetector default (deferToChild)
  final bool transparentFill; // wrap label in a Colors.transparent ColoredBox (D)
  final bool translucent; // C — gap tap also passes through to the layer behind
}

const _boxes = <_BoxSpec>[
  _BoxSpec(
    id: 'A',
    tag: 'deferToChild · default',
    gapRegisters: false,
    desc: 'GestureDetector wraps only the label, so taps in the empty gap do nothing.',
  ),
  _BoxSpec(
    id: 'B',
    tag: 'HitTestBehavior.opaque',
    gapRegisters: true,
    behavior: HitTestBehavior.opaque,
    desc: 'The whole box is tappable — the empty gap is included as a hit target.',
  ),
  _BoxSpec(
    id: 'C',
    tag: 'HitTestBehavior.translucent',
    gapRegisters: true,
    behavior: HitTestBehavior.translucent,
    translucent: true,
    desc: 'The whole box is tappable, and a gap tap also passes through to the layer '
        'behind (which highlights). opaque would have blocked that layer.',
  ),
  _BoxSpec(
    id: 'D',
    tag: 'Colors.transparent fill',
    gapRegisters: true,
    transparentFill: true,
    desc: 'Default behaviour, but the label sits on a transparent ColoredBox that '
        'hit-tests across the whole box — so the gap taps too. Looks identical to A.',
  ),
];

class _TapResult {
  const _TapResult({
    required this.letter,
    required this.zone, // 'letter' | 'empty gap'
    required this.registered,
    required this.passedThrough,
    required this.at,
  });

  final String letter;
  final String zone;
  final bool registered;
  final bool passedThrough;
  final DateTime at;
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  _TapResult? _last;
  final Map<String, _Outcome> _flash = {}; // per-box flash overlay
  final Set<String> _behind = {}; // per-box "behind layer" highlight (translucent pass-through)
  final Map<String, Timer> _timers = {};
  Timer? _ticker;
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    // Keeps the "N seconds ago" timestamp current.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    // Drives the pulsing status dot (1.6s full cycle).
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    for (final t in _timers.values) {
      t.cancel();
    }
    _pulse.dispose();
    super.dispose();
  }

  void _flashBox(String id, _Outcome outcome) {
    _timers[id]?.cancel();
    setState(() => _flash[id] = outcome);
    _timers[id] = Timer(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      setState(() => _flash.remove(id));
    });
  }

  void _flashBehind(String id) {
    final key = '$id#behind';
    _timers[key]?.cancel();
    setState(() => _behind.add(id));
    _timers[key] = Timer(const Duration(milliseconds: 750), () {
      if (!mounted) return;
      setState(() => _behind.remove(id));
    });
  }

  void _record(_BoxSpec box, String zone, bool registered, {bool passedThrough = false}) {
    setState(() => _last = _TapResult(
          letter: box.id,
          zone: zone,
          registered: registered,
          passedThrough: passedThrough,
          at: DateTime.now(),
        ));
  }

  // The label's own detector — a label tap always registers.
  void _onLabel(_BoxSpec box) {
    _record(box, 'letter', true);
    _flashBox(box.id, _Outcome.registered);
  }

  // The real demo detector fired — this only happens for GAP taps it absorbs
  // (B/C/D). Label taps are won by the inner label detector instead.
  void _onGapRegistered(_BoxSpec box) {
    // For C the catcher (below) fired on pointer-down just before this, so the
    // pass-through is a real, observed event — not an assumption.
    final passed = _behind.contains(box.id);
    _record(box, 'empty gap', true, passedThrough: passed);
    _flashBox(box.id, _Outcome.registered);
  }

  // The catcher Listener behind the box received the pointer — i.e. the real
  // demo detector did NOT absorb the tap at that point.
  void _onFellThrough(_BoxSpec box) {
    if (box.translucent) {
      // C: the gap tap passed through to the layer behind. Highlight it; the
      // status/registration is set by _onGapRegistered on pointer-up.
      _flashBehind(box.id);
    } else if (!box.gapRegisters) {
      // A: a genuine miss — the gap is dead.
      _record(box, 'empty gap', false);
      _flashBox(box.id, _Outcome.missed);
    }
  }

  String _relTime(DateTime ts) {
    final d = DateTime.now().difference(ts).inSeconds;
    if (d < 4) return 'just now';
    if (d < 60) return '${d}s ago';
    return '${d ~/ 60}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width < 640 ? 1 : (width < 1024 ? 2 : 4);
    final wrapMax = cols >= 4 ? 1320.0 : (cols == 2 ? 660.0 : 460.0);
    final titleSize = (width * 0.044).clamp(26.0, 38.0);

    return Scaffold(
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: wrapMax),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(titleSize),
                  const SizedBox(height: 24),
                  _statusBar(),
                  const SizedBox(height: 24),
                  _grid(cols),
                  const SizedBox(height: 24),
                  _whyNote(),
                  const SizedBox(height: 20),
                  _footer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──
  Widget _header(double titleSize) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _accentTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('FLUTTER', style: _mono(11, FontWeight.w600, _accent, spacing: 0.7)),
            ),
            const SizedBox(width: 10),
            Text('widgets · gesture', style: _mono(12, FontWeight.w500, _sub)),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'GestureDetector & HitTestBehavior',
          style: _inter(titleSize, FontWeight.w800, _ink, height: 1.05, spacing: titleSize * -0.02),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: _inter(15, FontWeight.w400, _body, height: 1.6),
            children: [
              const TextSpan(
                text: 'Each box wraps a centered label with an outline and generous '
                    'padding, leaving an empty gap between the label and the border. Tap the ',
              ),
              TextSpan(text: 'letter', style: _inter(15, FontWeight.w600, _ink, height: 1.6)),
              const TextSpan(text: ', then tap the '),
              TextSpan(text: 'empty gap', style: _inter(15, FontWeight.w600, _ink, height: 1.6)),
              const TextSpan(
                text: ' inside the outline — and watch which taps actually register.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Sticky status bar ──
  Widget _statusBar() {
    final last = _last;
    Color dot;
    Color halo;
    String line;
    String subtext;
    String time = '';

    if (last == null) {
      dot = const Color(0xFFCACACA);
      halo = const Color(0x40CACACA);
      line = 'Waiting for a tap';
      subtext = 'Tap a letter, then tap the empty gap inside an outline';
    } else if (last.registered) {
      dot = _accent;
      halo = _accent.withValues(alpha: 0.2);
      line = 'Box ${last.letter} — ${last.zone} tap registered'
          '${last.passedThrough ? ' (passed through)' : ''}';
      subtext = last.passedThrough
          ? 'The gap tap reached the layer behind'
          : 'This tap was inside a live hit target';
      time = _relTime(last.at);
    } else {
      dot = _miss;
      halo = _miss.withValues(alpha: 0.2);
      line = 'Box ${last.letter} — ${last.zone} tap missed';
      subtext = 'No hit — that area is not a tap target';
      time = _relTime(last.at);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Color.fromRGBO(20, 18, 24, 0.06), blurRadius: 20, offset: Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.82),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _statusBorder),
            ),
            child: Row(
              children: [
                _PulsingDot(color: dot, halo: halo, animation: _pulse),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _inter(14.5, FontWeight.w600, _ink),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        subtext,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: _inter(12.5, FontWeight.w400, _sub),
                      ),
                    ],
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(time, style: _mono(12, FontWeight.w500, _sub)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Grid of demo cards ──
  Widget _grid(int cols) {
    if (cols == 1) {
      return Column(
        children: [
          for (var i = 0; i < _boxes.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            _card(_boxes[i]),
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < _boxes.length; i += cols) {
      final chunk = _boxes.sublist(i, math.min(i + cols, _boxes.length));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < cols; j++) ...[
              if (j > 0) const SizedBox(width: 18),
              Expanded(child: j < chunk.length ? _card(chunk[j]) : const SizedBox()),
            ],
          ],
        ),
      ));
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 18),
          rows[i],
        ],
      ],
    );
  }

  Widget _card(_BoxSpec box) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: _cardShadow, blurRadius: 12, offset: Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
                child: Text(box.id, style: _inter(14, FontWeight.w700, Colors.white)),
              ),
              const SizedBox(width: 11),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _tagBg,
                    border: Border.all(color: _tagBorder),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    box.tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _mono(12, FontWeight.w500, _ink2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _InteractiveBox(
            box: box,
            flash: _flash[box.id],
            behind: _behind.contains(box.id),
            onLabel: () => _onLabel(box),
            onGapRegistered: () => _onGapRegistered(box),
            onFellThrough: () => _onFellThrough(box),
          ),
          const SizedBox(height: 16),
          Text(box.desc, style: _inter(13, FontWeight.w400, _descColor, height: 1.55)),
        ],
      ),
    );
  }

  // ── "Why this happens" note ──
  Widget _whyNote() {
    TextSpan code(String t) => TextSpan(text: t, style: _mono(12.5, FontWeight.w500, _ink));
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: _accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 9),
              Text('WHY THIS HAPPENS', style: _inter(12, FontWeight.w700, _ink2, spacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: _inter(13.5, FontWeight.w400, _body, height: 1.65),
              children: [
                const TextSpan(text: 'By default a '),
                code('GestureDetector'),
                const TextSpan(
                  text: ' only fires where one of its children is actually hit, so empty '
                      'padding around a label is dead. Set ',
                ),
                code('behavior: HitTestBehavior.opaque'),
                const TextSpan(text: ' to make the whole box a tap target. A '),
                code('Colors.transparent'),
                const TextSpan(
                  text: " fill works too, but it's an implicit side effect — prefer ",
                ),
                code('opaque'),
                const TextSpan(text: ', or a Material button, for real tap targets.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _footer() {
    return Center(
      child: TextButton.icon(
        onPressed: () => launchUrl(_repoUrl, webOnlyWindowName: '_blank'),
        icon: const Icon(Icons.code, size: 18, color: _sub),
        label: Text('View the source on GitHub', style: _inter(13, FontWeight.w500, _sub)),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.color, required this.halo, required this.animation});
  final Color color;
  final Color halo;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value; // 0 → 1 → 0
        return Opacity(
          opacity: 1 - 0.6 * t,
          child: Transform.scale(
            scale: 1 + 0.5 * t,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: halo, spreadRadius: 4)],
              ),
            ),
          ),
        );
      },
    );
  }
}

// The interactive demo box: a real GestureDetector (the behaviour under test)
// stacked over a raw Listener "catcher". A tap the detector ignores falls
// through to the catcher — which is how a dead-zone "miss" (A) and a
// translucent "pass-through" (C) become observable, using real hit-testing.
class _InteractiveBox extends StatelessWidget {
  const _InteractiveBox({
    required this.box,
    required this.flash,
    required this.behind,
    required this.onLabel,
    required this.onGapRegistered,
    required this.onFellThrough,
  });

  final _BoxSpec box;
  final _Outcome? flash;
  final bool behind;
  final VoidCallback onLabel;
  final VoidCallback onGapRegistered;
  final VoidCallback onFellThrough;

  @override
  Widget build(BuildContext context) {
    final label = GestureDetector(
      key: Key('label-${box.id}'),
      onTap: onLabel,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Text(box.id, style: _inter(32, FontWeight.w700, _ink2)),
      ),
    );

    Widget behaviorChild = Center(child: label);
    if (box.transparentFill) {
      behaviorChild = ColoredBox(color: Colors.transparent, child: Center(child: label));
    }

    return SizedBox(
      key: Key('box-${box.id}'),
      height: 138,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1) Catcher (raw pointer) + outline + the translucent "behind" layer.
          Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => onFellThrough(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              decoration: BoxDecoration(
                color: behind ? _behindColor.withValues(alpha: 0.9) : Colors.transparent,
                border: Border.all(color: _boxBorder, width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          // 2) Flash overlay — purely visual, never absorbs a tap.
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: flash == null ? 0 : 1,
              child: CustomPaint(
                painter: _FlashPainter(
                  registered: flash != _Outcome.missed,
                ),
              ),
            ),
          ),
          // 3) The real demo detector (the behaviour under test) wrapping the label.
          GestureDetector(
            behavior: box.behavior,
            onTap: onGapRegistered,
            child: behaviorChild,
          ),
        ],
      ),
    );
  }
}

class _FlashPainter extends CustomPainter {
  _FlashPainter({required this.registered});
  final bool registered;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(15));
    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = registered ? _accent.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.02);
    canvas.drawRRect(rrect, fill);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = registered ? _accent.withValues(alpha: 0.6) : _miss.withValues(alpha: 0.55);
    if (registered) {
      canvas.drawRRect(rrect, stroke);
    } else {
      // Dashed border for a "missed" tap.
      final path = Path()..addRRect(rrect);
      for (final metric in path.computeMetrics()) {
        var dist = 0.0;
        while (dist < metric.length) {
          final len = math.min(6.0, metric.length - dist);
          canvas.drawPath(metric.extractPath(dist, dist + len), stroke);
          dist += 10;
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlashPainter oldDelegate) => oldDelegate.registered != registered;
}
