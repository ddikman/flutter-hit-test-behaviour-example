import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

import 'demo_data.dart';
import 'theme.dart';
import 'widgets/debug_paint_note.dart';
import 'widgets/demo_card.dart';
import 'widgets/demo_header.dart';
import 'widgets/status_bar.dart';
import 'widgets/why_note.dart';

void main() {
  // This is a layout-debug teaching demo — show render bounds on the live site too.
  debugPaintSizeEnabled = true;
  runApp(const HitTestDemoApp());
}

class HitTestDemoApp extends StatelessWidget {
  const HitTestDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GestureDetector HitTestBehavior',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.bg),
      home: const DemoPage(),
    );
  }
}

class DemoPage extends StatefulWidget {
  const DemoPage({super.key});

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> with SingleTickerProviderStateMixin {
  BoxSpec? _last;
  DateTime? _lastAt;
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
    _pulse.dispose();
    super.dispose();
  }

  void _tap(BoxSpec box) {
    setState(() {
      _last = box;
      _lastAt = DateTime.now();
    });
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
                  DemoHeader(titleSize: titleSize),
                  const SizedBox(height: 24),
                  StatusBar(last: _last, at: _lastAt, pulse: _pulse),
                  const SizedBox(height: 24),
                  _grid(cols),
                  const SizedBox(height: 24),
                  const DebugPaintNote(),
                  const SizedBox(height: 24),
                  const WhyNote(),
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

  /// Lays the cards out in [cols] columns with equal row heights.
  Widget _grid(int cols) {
    final stretch = cols > 1;
    Widget cardFor(BoxSpec box) => DemoCard(box: box, onTap: () => _tap(box), stretch: stretch);

    if (cols == 1) {
      return Column(
        children: [
          for (var i = 0; i < kBoxes.length; i++) ...[
            if (i > 0) const SizedBox(height: 18),
            cardFor(kBoxes[i]),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < kBoxes.length; i += cols) {
      final chunk = kBoxes.sublist(i, math.min(i + cols, kBoxes.length));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < cols; j++) ...[
              if (j > 0) const SizedBox(width: 18),
              Expanded(child: j < chunk.length ? cardFor(chunk[j]) : const SizedBox()),
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

  Widget _footer() {
    return Center(
      child: TextButton.icon(
        onPressed: () => launchUrl(kRepoUrl, webOnlyWindowName: '_blank'),
        icon: const Icon(Icons.code, size: 18, color: AppColors.sub),
        label: Text('View the source on GitHub', style: inter(13, FontWeight.w500, AppColors.sub)),
      ),
    );
  }
}
