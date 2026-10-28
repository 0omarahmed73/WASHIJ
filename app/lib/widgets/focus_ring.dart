import 'package:flutter/material.dart';

import '../theme/tokens.dart';

class FocusRing extends StatefulWidget {
  const FocusRing({super.key, required this.child});

  final Widget child;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> {
  var _focused = false;

  @override
  Widget build(BuildContext context) => Focus(
    canRequestFocus: false,
    skipTraversal: true,
    includeSemantics: false,
    onFocusChange: (focused) {
      if (_focused != focused) setState(() => _focused = focused);
    },
    child: Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (_focused)
          Positioned.fill(
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: DecoratedBox(
                  key: const ValueKey('washij-focus-ring'),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: WashijColors.starYellow,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}
