import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models/art_reading.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'focus_ring.dart';

class ArtReadingCard extends StatelessWidget {
  const ArtReadingCard({super.key, required this.reading});

  final ArtReading reading;

  @override
  Widget build(BuildContext context) {
    final excerpt = _nonEmpty(reading.subtitle);
    final publication = reading.publication.trim();
    final author = reading.author.trim();
    final hasValidUrl = _sourceUri(reading.url) != null;

    return Semantics(
      link: hasValidUrl,
      label: 'قراءة ${reading.title} من $publication',
      child: Material(
        color: WashijColors.deepBlue,
        child: Ink(
          decoration: const BoxDecoration(
            border: Border.fromBorderSide(
              BorderSide(color: WashijColors.hairline),
            ),
          ),
          child: FocusRing(
            child: InkWell(
              onTap: () => _openSource(context),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      reading.title,
                      style: WashijTypography.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 20,
                      runSpacing: 10,
                      children: [
                        if (publication.isNotEmpty)
                          _ReadingMetadata(
                            icon: Icons.article_outlined,
                            label: 'المصدر',
                            value: publication,
                          ),
                        if (author.isNotEmpty)
                          _ReadingMetadata(
                            icon: Icons.person_outline,
                            label: 'الكاتب',
                            value: author,
                          ),
                        if (reading.publishedAt case final publishedAt?)
                          _ReadingMetadata(
                            icon: Icons.calendar_today_outlined,
                            label: 'التاريخ',
                            value: MaterialLocalizations.of(context)
                                .formatMediumDate(publishedAt),
                          ),
                      ],
                    ),
                    if (excerpt != null) ...[
                      const SizedBox(height: 18),
                      const Divider(color: WashijColors.hairline),
                      const SizedBox(height: 14),
                      Text(
                        excerpt,
                        style: WashijTypography.textTheme.bodyMedium?.copyWith(
                          color: WashijColors.mist,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Icon(
                          Icons.open_in_new,
                          size: 18,
                          color: WashijColors.mutedSky,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'اقرأ المقال الأصلي',
                          style: WashijTypography.textTheme.labelLarge
                              ?.copyWith(color: WashijColors.mutedSky),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openSource(BuildContext context) async {
    final uri = _sourceUri(reading.url);
    if (uri == null) {
      _showMessage(context, 'رابط المصدر غير صالح.');
      return;
    }

    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && context.mounted) {
        _showMessage(context, 'تعذّر فتح الرابط. حاول مرة أخرى.');
      }
    } on Exception {
      if (context.mounted) {
        _showMessage(context, 'تعذّر فتح الرابط. حاول مرة أخرى.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)
        ?.showSnackBar(SnackBar(content: Text(message)));
  }

  static Uri? _sourceUri(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty) {
      return null;
    }
    return uri;
  }

  static String? _nonEmpty(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }
}

class _ReadingMetadata extends StatelessWidget {
  const _ReadingMetadata({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: WashijColors.mutedSky),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: WashijTypography.textTheme.bodySmall?.copyWith(
            color: WashijColors.mist,
          ),
        ),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: WashijTypography.textTheme.bodySmall,
          ),
        ),
      ],
    ),
  );
}
