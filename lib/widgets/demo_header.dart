import 'package:flutter/material.dart';

import '../theme.dart';

/// The page header: the FLUTTER pill, the title, and the intro paragraph.
class DemoHeader extends StatelessWidget {
  const DemoHeader({super.key, required this.titleSize});

  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.accentTint,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('FLUTTER', style: mono(11, FontWeight.w600, AppColors.accent, spacing: 0.7)),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'widgets · gesture',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: mono(12, FontWeight.w500, AppColors.sub),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'GestureDetector & HitTestBehavior',
          style: inter(titleSize, FontWeight.w800, AppColors.ink, height: 1.05, spacing: titleSize * -0.02),
        ),
        const SizedBox(height: 14),
        Text.rich(
          TextSpan(
            style: inter(15, FontWeight.w400, AppColors.body, height: 1.6),
            children: [
              const TextSpan(
                text: 'Each box wraps a centered label with an outline and generous '
                    'padding, leaving an empty gap between the label and the border. Tap the ',
              ),
              TextSpan(text: 'letter', style: inter(15, FontWeight.w600, AppColors.ink, height: 1.6)),
              const TextSpan(text: ', then tap the '),
              TextSpan(text: 'empty gap', style: inter(15, FontWeight.w600, AppColors.ink, height: 1.6)),
              const TextSpan(text: ' inside the outline — and watch which taps actually register.'),
            ],
          ),
        ),
      ],
    );
  }
}
