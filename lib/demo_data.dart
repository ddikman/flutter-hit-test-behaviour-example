import 'package:flutter/widgets.dart';

/// One demo box: a label inside a contrast container, wired to a
/// [GestureDetector] configured with [behavior].
class BoxSpec {
  const BoxSpec({
    required this.id,
    required this.tag,
    required this.desc,
    required this.layoutPseudo,
    this.behavior,
    this.transparentFill = false,
  });

  /// The letter shown in the box and the badge.
  final String id;

  /// The behaviour label shown in the card's tag pill.
  final String tag;

  /// One-line explanation under the box.
  final String desc;

  /// Widget-tree pseudocode for this box's interactive area.
  final String layoutPseudo;

  /// The HitTestBehavior under test. `null` is the GestureDetector default
  /// (deferToChild), so only the label is a hit target.
  final HitTestBehavior? behavior;

  /// When true, the padding is wrapped in a `Colors.transparent` [ColoredBox],
  /// which hit-tests across the whole box even under the default behaviour (box D).
  final bool transparentFill;
}

const kBoxes = <BoxSpec>[
  BoxSpec(
    id: 'A',
    tag: 'deferToChild · default',
    layoutPseudo: '''Container
└─ GestureDetector          // deferToChild (default)
   └─ SizedBox.expand
      └─ Padding(40)
         └─ Align.center
            └─ Text('A')''',
    desc: 'GestureDetector wraps the same padded label as the others, but under '
        'deferToChild only the Text render box (innermost cyan outline) registers '
        'taps — the blue padding region does not.',
  ),
  BoxSpec(
    id: 'B',
    tag: 'HitTestBehavior.opaque',
    behavior: HitTestBehavior.opaque,
    layoutPseudo: '''Container
└─ GestureDetector(opaque)
   └─ SizedBox.expand
      └─ Padding(40)
         └─ Align.center
            └─ Text('B')''',
    desc: 'The whole box is one tap target — the empty gap is included.',
  ),
  BoxSpec(
    id: 'C',
    tag: 'HitTestBehavior.translucent',
    behavior: HitTestBehavior.translucent,
    layoutPseudo: '''Container
└─ GestureDetector(translucent)
   └─ SizedBox.expand
      └─ Padding(40)
         └─ Align.center
            └─ Text('C')''',
    desc: 'Also makes the whole box tappable; unlike opaque it lets a widget '
        'behind it receive the tap too.',
  ),
  BoxSpec(
    id: 'D',
    tag: 'Colors.transparent fill',
    transparentFill: true,
    layoutPseudo: '''Container
└─ GestureDetector          // deferToChild (default)
   └─ SizedBox.expand
      └─ ColoredBox(transparent)
         └─ Padding(40)
            └─ Align.center
               └─ Text('D')''',
    desc: 'Default behaviour, but a Colors.transparent ColoredBox wraps the '
        'padding so the whole box hit-tests — gap taps register too. '
        'Looks identical to A.',
  ),
];

/// The GitHub repository for this demo, linked from the footer.
final Uri kRepoUrl =
    Uri.parse('https://github.com/ddikman/flutter-hit-test-behaviour-example');
