import 'package:flutter/material.dart';

import '../demo_data.dart';
import '../theme.dart';

/// A single demo card: the letter badge, the behaviour tag, the interactive
/// box, and a one-line description.
class DemoCard extends StatelessWidget {
  const DemoCard({super.key, required this.box, required this.onTap});

  final BoxSpec box;
  final VoidCallback onTap;

  static const _boxHeight = 138.0;
  static const _labelPadding = EdgeInsets.all(40);

  @override
  Widget build(BuildContext context) {
    final label = Text(box.id, style: inter(32, FontWeight.w700, AppColors.ink2));

    final paddedLabel = Padding(
      padding: _labelPadding,
      child: Align(alignment: Alignment.center, child: label),
    );

    // All boxes share the same SizedBox + Padding layout. Hit-test behaviour differs:
    // A — deferToChild: only Text registers; blue padding is layout-only.
    // B/C — opaque/translucent: GestureDetector claims the full cyan rectangle.
    // D — transparent ColoredBox fill makes the padding region hit-testable too.
    final Widget gestureChild;
    if (box.transparentFill) {
      gestureChild = ColoredBox(
        color: Colors.transparent,
        child: paddedLabel,
      );
    } else {
      gestureChild = paddedLabel;
    }

    final interactiveBox = Container(
      width: double.infinity,
      height: _boxHeight,
      decoration: BoxDecoration(
        color: AppColors.boxBg,
        border: Border.all(color: AppColors.boxBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: GestureDetector(
        behavior: box.behavior, // A: null (deferToChild) · B: opaque · C: translucent · D: null
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: _boxHeight,
          child: gestureChild,
        ),
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
        mainAxisSize: MainAxisSize.min,
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
          SizedBox(
            width: double.infinity,
            child: Text(box.desc, style: inter(13, FontWeight.w400, AppColors.desc, height: 1.55)),
          ),
        ],
      ),
    );
  }
}
