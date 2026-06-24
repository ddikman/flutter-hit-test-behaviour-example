import 'package:flutter/material.dart';

import '../theme.dart';

/// Explains the colours drawn by [debugPaintSizeEnabled].
class DebugPaintNote extends StatelessWidget {
  const DebugPaintNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
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
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'READING debugPaintSize',
                  style: inter(12, FontWeight.w700, AppColors.ink2, spacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/screenshot.png',
              width: double.infinity,
              fit: BoxFit.fitWidth,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'This page enables Flutter’s built-in layout overlay in debug builds. '
            'Each colour marks a different part of the render tree:',
            style: inter(13.5, FontWeight.w400, AppColors.body, height: 1.65),
          ),
          const SizedBox(height: 12),
          _legendRow(
            const Color(0xFF00FFFF),
            'Cyan outline',
            'the layout bounds of every render box (every sized widget).',
          ),
          const SizedBox(height: 8),
          _legendRow(
            const Color(0x900090FF),
            'Blue fill',
            'the inset region of a Padding widget (space between the parent’s edge and its child).',
          ),
          const SizedBox(height: 8),
          _legendRow(
            const Color(0x90909090),
            'Grey fill',
            'unused space left over by alignment or flex layout (e.g. a centred child smaller than its parent).',
          ),
          const SizedBox(height: 12),
          Text(
            'These show layout geometry, not hit targets — but for box A only the innermost box '
            '(the Text) actually receives taps under deferToChild, while B–D fill or claim the '
            'full cyan rectangle.',
            style: inter(13.5, FontWeight.w400, AppColors.body, height: 1.65),
          ),
        ],
      ),
    );
  }

  Widget _legendRow(Color swatch, String label, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3, right: 10),
          decoration: BoxDecoration(
            color: swatch,
            border: Border.all(color: AppColors.boxBorder),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: inter(13.5, FontWeight.w400, AppColors.body, height: 1.65),
              children: [
                TextSpan(text: label, style: inter(13.5, FontWeight.w600, AppColors.ink, height: 1.65)),
                TextSpan(text: ' — $desc'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
