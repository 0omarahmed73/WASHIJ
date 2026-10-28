import 'package:flutter/material.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'page_width.dart';
import 'thread_separator.dart';

class ManifestoBand extends StatelessWidget {
  const ManifestoBand({super.key});

  @override
  Widget build(BuildContext context) => Container(
    color: WashijColors.deepBlue,
    child: PageWidth(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'عن المتحف',
              style: TextStyle(color: WashijColors.mutedSky),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 940),
              child: Text(
                'الفن لا يقف في إطار واحد. لوحةٌ تلمح إلى فنان، وفنانٌ يصل إلى مدرسة، ومدرسةٌ تفتح بابًا لزمنٍ كامل.',
                style: WashijTypography.textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            const ThreadSeparator(),
          ],
        ),
      ),
    ),
  );
}
