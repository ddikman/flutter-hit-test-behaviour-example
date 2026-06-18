import 'package:flutter/material.dart';

import '../theme.dart';

/// The "Why this happens" explanatory card below the demo grid.
class WhyNote extends StatelessWidget {
  const WhyNote({super.key});

  @override
  Widget build(BuildContext context) {
    TextSpan code(String t) => TextSpan(text: t, style: mono(12.5, FontWeight.w500, AppColors.ink));
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
              Text('WHY THIS HAPPENS', style: inter(12, FontWeight.w700, AppColors.ink2, spacing: 0.5)),
            ],
          ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              style: inter(13.5, FontWeight.w400, AppColors.body, height: 1.65),
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
                const TextSpan(text: " fill works too, but it's an implicit side effect — prefer "),
                code('opaque'),
                const TextSpan(text: ', or a Material button, for real tap targets.'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
