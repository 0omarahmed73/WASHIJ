import 'package:flutter/material.dart';

import '../paint/long_thread.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({super.key, required this.title, this.detail});

  final String title;
  final String? detail;

  @override
  Widget build(BuildContext context) => MuseumPage(
    slivers: [
      SliverToBoxAdapter(
        child: PageWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 72),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: WashijTypography.textTheme.displayMedium),
                if (detail != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    detail!,
                    style: const TextStyle(color: WashijColors.mist),
                  ),
                ],
                const SizedBox(height: 24),
                const Text(
                  'كل لوحة خيط في حكاية الفن',
                  style: TextStyle(color: WashijColors.mist, fontSize: 18),
                ),
                const SizedBox(height: 32),
                const LongThread(width: 280),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
