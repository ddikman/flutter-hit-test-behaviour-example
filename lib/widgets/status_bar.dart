import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../demo_data.dart';
import '../theme.dart';

/// The frosted status bar that reports the most recent tap. When nothing has
/// registered yet (or after tapping box A's dead gap) it stays on "Waiting".
class StatusBar extends StatelessWidget {
  const StatusBar({super.key, required this.last, required this.at, required this.pulse});

  final BoxSpec? last;
  final DateTime? at;
  final Animation<double> pulse;

  String _relTime(DateTime ts) {
    final d = DateTime.now().difference(ts).inSeconds;
    if (d < 4) return 'just now';
    if (d < 60) return '${d}s ago';
    return '${d ~/ 60}m ago';
  }

  @override
  Widget build(BuildContext context) {
    final box = last;
    final Color dot;
    final String line;
    final Widget subtext;
    String time = '';

    if (box == null) {
      dot = AppColors.waitingDot;
      line = 'Waiting for a tap';
      subtext = Text(
        'Tap a box — and try the empty gap inside box A',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: inter(12.5, FontWeight.w400, AppColors.sub),
      );
    } else {
      dot = AppColors.accent;
      line = 'Box ${box.id} tapped';
      subtext = Text(
        box.tag,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: mono(12, FontWeight.w500, AppColors.sub),
      );
      if (at != null) time = _relTime(at!);
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: AppColors.statusShadow, blurRadius: 20, offset: Offset(0, 4)),
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
              border: Border.all(color: AppColors.statusBorder),
            ),
            child: Row(
              children: [
                _PulsingDot(color: dot, animation: pulse),
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
                        style: inter(14.5, FontWeight.w600, AppColors.ink),
                      ),
                      const SizedBox(height: 1),
                      subtext,
                    ],
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Text(time, style: mono(12, FontWeight.w500, AppColors.sub)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.color, required this.animation});

  final Color color;
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
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.25), spreadRadius: 4)],
              ),
            ),
          ),
        );
      },
    );
  }
}
