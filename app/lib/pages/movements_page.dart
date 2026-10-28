import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog.dart';
import '../data/models/movement.dart';
import '../state/providers.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/museum_page.dart';
import '../widgets/page_width.dart';
import '../widgets/section_header.dart';
import '../widgets/focus_ring.dart';

class MovementsPage extends ConsumerWidget {
  const MovementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: MuseumPage(
        slivers: [
          catalog.when(
            data: (value) => SliverToBoxAdapter(
              child: PageWidth(child: _MovementsIndex(catalog: value)),
            ),
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'جارٍ تحميل دليل المدارس الفنية',
                loading: true,
              ),
            ),
            error: (error, stackTrace) => SliverFillRemaining(
              hasScrollBody: false,
              child: _CatalogStatus(
                message: 'تعذّر تحميل دليل المدارس الفنية.',
                onRetry: () => ref.invalidate(catalogProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementsIndex extends StatelessWidget {
  const _MovementsIndex({required this.catalog});

  final Catalog catalog;

  @override
  Widget build(BuildContext context) {
    final movements = catalog.movements.values.toList(growable: false);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionHeader(title: 'المدارس الفنية'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Text(
              'حركات فنية جمعت الفنانين والأعمال حول رؤى وأساليب مشتركة.',
              style: WashijTypography.textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 36),
          if (movements.isEmpty)
            const _EmptyState(message: 'لا توجد مدارس فنية متاحة الآن.')
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 960
                    ? 3
                    : constraints.maxWidth >= 600
                    ? 2
                    : 1;
                const gap = 20.0;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final movement in movements)
                      SizedBox(
                        width: width,
                        child: _MovementCard(movement: movement),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

class _MovementCard extends StatelessWidget {
  const _MovementCard({required this.movement});

  final Movement movement;

  @override
  Widget build(BuildContext context) => Semantics(
    link: true,
    label: 'المدرسة الفنية ${movement.nameAr}، ${movement.nameOrig}',
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
            onTap: () =>
                context.push('/movement/${Uri.encodeComponent(movement.id)}'),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    movement.nameAr,
                    style: WashijTypography.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    movement.nameOrig,
                    textDirection: TextDirection.ltr,
                    style: WashijTypography.englishDisplay.copyWith(
                      color: WashijColors.mist,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _MovementFact(label: 'الفترة', value: movement.period),
                  if (movement.place.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _MovementFact(label: 'المكان', value: movement.place),
                  ],
                  if (movement.line.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      movement.line,
                      style: WashijTypography.textTheme.bodyMedium?.copyWith(
                        color: WashijColors.mutedSky,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _MovementFact extends StatelessWidget {
  const _MovementFact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 62,
        child: Text(label, style: const TextStyle(color: WashijColors.mist)),
      ),
      Expanded(child: Text(value)),
    ],
  );
}

class _CatalogStatus extends StatelessWidget {
  const _CatalogStatus({
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            Semantics(
              label: 'جارٍ التحميل',
              child: SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            const Icon(Icons.error_outline, color: WashijColors.danger),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ],
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(
      color: WashijColors.deepBlue,
      border: Border.fromBorderSide(BorderSide(color: WashijColors.hairline)),
    ),
    child: Text(message, style: const TextStyle(color: WashijColors.mist)),
  );
}
