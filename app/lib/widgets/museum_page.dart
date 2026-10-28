import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/tokens.dart';
import 'page_width.dart';

class MuseumPage extends StatelessWidget {
  const MuseumPage({
    super.key,
    required this.slivers,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.physics,
  });

  final List<Widget> slivers;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) => CustomScrollView(
    keyboardDismissBehavior: keyboardDismissBehavior,
    physics: physics,
    slivers: [
      ...slivers,
      const SliverToBoxAdapter(child: MuseumFooter()),
    ],
  );
}

class MuseumFooter extends StatelessWidget {
  const MuseumFooter({super.key});

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border(top: BorderSide(color: WashijColors.hairline)),
    ),
    padding: const EdgeInsets.symmetric(vertical: 32),
    child: PageWidth(
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'كل لوحة خيط في حكاية الفن',
                style: TextStyle(color: WashijColors.ivory),
              ),
              SizedBox(height: 8),
              Text(
                'المعلومات والصور موثقة بروابط مصادرها.',
                style: TextStyle(color: WashijColors.mist, fontSize: 13),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                '© WASHIJ',
                textDirection: TextDirection.ltr,
                style: TextStyle(color: WashijColors.mutedSky),
              ),
              TextButton(
                onPressed: () => context.go('/about'),
                style: TextButton.styleFrom(
                  foregroundColor: WashijColors.ivory,
                  minimumSize: const Size(44, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: const Text('عن المطوّر'),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
