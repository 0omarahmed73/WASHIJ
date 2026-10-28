import 'package:flutter/material.dart';

class PageWidth extends StatelessWidget {
  const PageWidth({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontal = constraints.maxWidth < 600 ? 20.0 : 40.0;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      );
    },
  );
}
