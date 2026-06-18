import 'package:flutter/material.dart';

import '../demo_data.dart';
import '../theme.dart';
import 'outlined_box.dart';

/// A single demo card: the letter badge, the behaviour tag, the interactive
/// box, and a one-line description.
class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.box, required this.onTap});

  final BoxSpec box;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = Center(child: Text(box.id, style: inter(32, FontWeight.w700, AppColors.ink2)));

    // The demo itself: a plain GestureDetector with this box's HitTestBehavior,
    // wrapping only the label. OutlinedBox draws the frame around it (as a
    // parent), so the outline is never part of the hit-test target.
    final interactiveBox = OutlinedBox(
      child: GestureDetector(
        behavior: box.behavior, // A: null (deferToChild) · B: opaque · C: translucent · D: null
        onTap: onTap,
        child: box.transparentFill
            ? ColoredBox(color: Colors.transparent, child: label) // D
            : label,
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [BoxShadow(color: AppColors.cardShadow, blurRadius: 12, offset: Offset(0, 2))],
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
                decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                child: Text(box.id, style: inter(14, FontWeight.w700, Colors.white)),
              ),
              const SizedBox(width: 11),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    border: Border.all(color: AppColors.tagBorder),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    box.tag,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: mono(12, FontWeight.w500, AppColors.ink2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          interactiveBox,
          const SizedBox(height: 16),
          Text(box.desc, style: inter(13, FontWeight.w400, AppColors.desc, height: 1.55)),
        ],
      ),
    );
  }
}
