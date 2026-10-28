import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: WashijTypography.textTheme.headlineMedium?.copyWith(
              color: WashijColors.ivory,
            ),
          ),
        ),
        ?action,
      ],
    ),
  );
}
