import 'package:flutter/material.dart';

import '../theme.dart';

/// The rounded outline and fixed height shared by every demo box.
///
/// This is styling only. It draws the border as a *parent* of the
/// GestureDetector it wraps, so the outline is never part of the hit-test
/// target — which is exactly why box A (deferToChild) ignores taps in the gap.
class OutlinedBox extends StatelessWidget {
  const OutlinedBox({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 138,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.boxBorder, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    );
  }
}
