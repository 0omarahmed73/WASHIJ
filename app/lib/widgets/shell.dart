import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../paint/wordmark.dart';
import '../theme/tokens.dart';
import 'drawer.dart';
import 'page_width.dart';
import 'search_overlay.dart';
import 'focus_ring.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.path, required this.child});

  final String path;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return PopScope<Object?>(
      canPop: router.canPop() || path == '/',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && path != '/') router.go('/');
      },
      child: Scaffold(
        backgroundColor: WashijColors.midnight,
        endDrawer: const WashijDrawer(),
        body: SafeArea(
          child: Column(
            children: [
              _Header(path: path),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.path});

  final String path;

  static const _destinations = [
    ('/', 'الرئيسية', 'home'),
    ('/artworks', 'اللوحات', 'artworks'),
    ('/artists', 'الفنانون', 'artists'),
    ('/movements', 'المدارس الفنية', 'movements'),
    ('/readings', 'قراءات الفن', 'readings'),
  ];

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: WashijColors.midnight,
      border: Border(bottom: BorderSide(color: WashijColors.hairline)),
    ),
    child: PageWidth(
      child: SizedBox(
        height: 82,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 760;
            return Row(
              children: [
                FocusRing(
                  child: InkWell(
                    onTap: () => context.go('/'),
                    child: const Wordmark(symbolSize: 38, showEnglish: true),
                  ),
                ),
                const Spacer(),
                if (!compact)
                  for (final (location, label, key) in _destinations)
                    _NavLink(
                      location: location,
                      label: label,
                      selected: _isSelected(key, path),
                    ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'بحث',
                  onPressed: () => showWashijSearch(context),
                  icon: const Icon(Icons.search),
                ),
                if (compact)
                  Builder(
                    builder: (context) => IconButton(
                      tooltip: 'القائمة',
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      icon: const Icon(Icons.menu),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );

  bool _isSelected(String destination, String currentPath) {
    if (destination == 'home') return currentPath == '/';
    return currentPath == '/$destination' ||
        currentPath.startsWith(
          '/${destination.substring(0, destination.length - 1)}',
        );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink({
    required this.location,
    required this.label,
    required this.selected,
  });

  final String location;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(start: 4),
    child: TextButton(
      onPressed: () => context.go(location),
      style: TextButton.styleFrom(
        foregroundColor: selected
            ? WashijColors.starYellow
            : WashijColors.ivory,
        padding: const EdgeInsets.symmetric(horizontal: 14),
      ),
      child: Text(label),
    ),
  );
}

void showWashijSearch(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) => SearchOverlay(
      onSelect: (location) {
        Navigator.of(dialogContext).pop();
        context.push(location);
      },
    ),
  );
}
