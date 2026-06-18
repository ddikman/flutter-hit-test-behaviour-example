import 'package:flutter/widgets.dart';

/// One demo box: a label shown inside an outline, wired to a [GestureDetector]
/// configured with [behavior].
class BoxSpec {
  const BoxSpec({
    required this.id,
    required this.tag,
    required this.desc,
    this.behavior,
    this.transparentFill = false,
  });

  /// The letter shown in the box and the badge.
  final String id;

  /// The behaviour label shown in the card's tag pill.
  final String tag;

  /// One-line explanation under the box.
  final String desc;

  /// The HitTestBehavior under test. `null` is the GestureDetector default
  /// (deferToChild), so only the label is a hit target.
  final HitTestBehavior? behavior;

  /// When true, the label sits on a `Colors.transparent` ColoredBox, which
  /// hit-tests across the whole box even under the default behaviour (box D).
  final bool transparentFill;
}

const kBoxes = <BoxSpec>[
  BoxSpec(
    id: 'A',
    tag: 'deferToChild · default',
    desc: 'GestureDetector wraps only the label, so a tap in the empty gap does '
        'nothing — only the letter registers.',
  ),
  BoxSpec(
    id: 'B',
    tag: 'HitTestBehavior.opaque',
    behavior: HitTestBehavior.opaque,
    desc: 'The whole box is one tap target — the empty gap is included.',
  ),
  BoxSpec(
    id: 'C',
    tag: 'HitTestBehavior.translucent',
    behavior: HitTestBehavior.translucent,
    desc: 'Also makes the whole box tappable; unlike opaque it lets a widget '
        'behind it receive the tap too.',
  ),
  BoxSpec(
    id: 'D',
    tag: 'Colors.transparent fill',
    transparentFill: true,
    desc: 'Default behaviour, but the label sits on a Colors.transparent '
        'ColoredBox that hit-tests across the whole box — so the gap taps too. '
        'Looks identical to A.',
  ),
];

/// The GitHub repository for this demo, linked from the footer.
final Uri kRepoUrl =
    Uri.parse('https://github.com/ddikman/flutter-hit-test-behaviour-example');
