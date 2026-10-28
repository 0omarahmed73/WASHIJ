import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/museum_page.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key, this.path = ''});

  final String path;

  @override
  Widget build(BuildContext context) => MuseumPage(
    slivers: [
      SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'لم نعثر على هذه الصفحة',
                  style: WashijTypography.textTheme.headlineMedium,
                ),
                if (path.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    path,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(color: WashijColors.mist),
                  ),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/artworks'),
                  child: const Text('استكشف اللوحات'),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
