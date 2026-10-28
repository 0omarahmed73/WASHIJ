import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../paint/long_thread.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/focus_ring.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _links = [
    _ProfileLink(
      label: 'GitHub',
      url: 'https://github.com/0omarahmed73',
      icon: Icons.code,
    ),
    _ProfileLink(
      label: 'LinkedIn',
      url: 'https://linkedin.com/in/0omarahmed73',
      icon: Icons.work_outline,
    ),
    _ProfileLink(
      label: 'الموقع الشخصي',
      url: 'https://www.omarasaeed.dev/',
      icon: Icons.language,
    ),
  ];

  @override
  Widget build(BuildContext context) => MuseumPage(
    slivers: [
      SliverToBoxAdapter(
        child: PageWidth(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 850;
              return Padding(
                padding: const EdgeInsetsDirectional.only(top: 64, bottom: 88),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Expanded(flex: 3, child: _ProfileHeading()),
                          const SizedBox(width: 48),
                          Expanded(flex: 2, child: _MonogramPanel(height: 300)),
                        ],
                      )
                    else ...[
                      const _ProfileHeading(),
                      const SizedBox(height: 36),
                      const _MonogramPanel(height: 230),
                    ],
                    const SizedBox(height: 56),
                    const _LinksHeading(),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, linkConstraints) {
                        final columns = linkConstraints.maxWidth >= 950
                            ? 3
                            : linkConstraints.maxWidth >= 620
                            ? 2
                            : 1;
                        const gap = 12.0;
                        final cardWidth =
                            (linkConstraints.maxWidth - gap * (columns - 1)) /
                            columns;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (final link in _links)
                              SizedBox(
                                width: cardWidth,
                                child: _ProfileLinkCard(link: link),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

class _ProfileHeading extends StatelessWidget {
  const _ProfileHeading();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            child: Divider(color: WashijColors.starYellow, thickness: 2),
          ),
          SizedBox(width: 12),
          Text(
            'ملف المطوّر',
            style: TextStyle(
              color: WashijColors.mutedSky,
              fontSize: 14,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      const SizedBox(height: 20),
      Text(
        'عمر أ. سعيد',
        style: WashijTypography.textTheme.displayLarge?.copyWith(
          color: WashijColors.ivory,
          fontSize: 58,
          height: 1.25,
        ),
      ),
      const SizedBox(height: 8),
      const Text(
        'Full Stack Web Developer',
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: WashijFonts.englishDisplay,
          fontSize: 32,
          fontWeight: FontWeight.w500,
          color: WashijColors.mist,
          height: 1.25,
        ),
      ),
      const SizedBox(height: 24),
      const LongThread(width: 210, height: 32),
    ],
  );
}

class _MonogramPanel extends StatelessWidget {
  const _MonogramPanel({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    decoration: BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.all(color: WashijColors.hairline),
    ),
    child: Stack(
      children: [
        const PositionedDirectional(
          top: 18,
          start: 18,
          child: Text(
            'وَشيج · 01',
            textDirection: TextDirection.rtl,
            style: TextStyle(color: WashijColors.mutedSky, fontSize: 12),
          ),
        ),
        Center(
          child: Text(
            'ع',
            style: WashijTypography.textTheme.displayLarge?.copyWith(
              color: WashijColors.ivory,
              fontSize: height * 0.58,
              height: 1,
            ),
          ),
        ),
        const PositionedDirectional(
          top: 42,
          start: 20,
          end: 20,
          child: LongThread(width: 180, height: 28),
        ),
      ],
    ),
  );
}

class _LinksHeading extends StatelessWidget {
  const _LinksHeading();

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'روابط التواصل والعمل',
        style: WashijTypography.textTheme.headlineMedium?.copyWith(
          color: WashijColors.ivory,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'تصفّح أعمالي وحساباتي المهنية',
        style: TextStyle(color: WashijColors.mist, fontSize: 14),
      ),
    ],
  );
}

class _ProfileLinkCard extends StatelessWidget {
  const _ProfileLinkCard({required this.link});

  final _ProfileLink link;

  @override
  Widget build(BuildContext context) => FocusRing(
    child: Material(
      color: WashijColors.deepBlue,
      child: InkWell(
        onTap: () => _openProfileLink(context, link.url),
        hoverColor: WashijColors.nightRaised,
        splashColor: WashijColors.starYellow.withValues(alpha: 0.08),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: WashijColors.borderControl),
          ),
          child: Row(
            children: [
              Icon(link.icon, color: WashijColors.starYellow, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      link.label,
                      style: const TextStyle(
                        color: WashijColors.ivory,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      Uri.parse(link.url).host +
                          Uri.parse(link.url).path
                              .replaceFirst(RegExp(r'/$'), ''),
                      textDirection: TextDirection.ltr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: WashijColors.mist,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.open_in_new,
                color: WashijColors.mutedSky,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _ProfileLink {
  const _ProfileLink({
    required this.label,
    required this.url,
    required this.icon,
  });

  final String label;
  final String url;
  final IconData icon;
}

Future<void> _openProfileLink(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || uri.scheme != 'https') {
    _showLinkError(context);
    return;
  }
  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) _showLinkError(context);
  } on Object {
    if (context.mounted) _showLinkError(context);
  }
}

void _showLinkError(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('تعذّر فتح الرابط'),
      backgroundColor: WashijColors.danger,
    ),
  );
}
