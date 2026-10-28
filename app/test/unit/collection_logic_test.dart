import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:washij/data/bundled_source.dart';
import 'package:washij/state/collection_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('search matches Arabic and Latin artwork and artist names', () async {
    final catalog = await const BundledSource().load();

    final arabic = selectCollection(
      catalog,
      const CollectionState(query: 'ليلة'),
    );
    final latin = selectCollection(
      catalog,
      const CollectionState(query: 'starry'),
    );

    expect(arabic.map((work) => work.id), contains('starry-night'));
    expect(latin.map((work) => work.id), contains('starry-night'));
  });

  test('movement, artist and period filters combine', () async {
    final catalog = await const BundledSource().load();

    final works = selectCollection(
      catalog,
      const CollectionState(
        movementId: 'dutch',
        artistId: 'vermeer',
        periodId: 'p2',
      ),
    );

    expect(works.map((work) => work.id).toSet(), {
      'girl-pearl-earring',
      'milkmaid',
    });
  });

  test('date and title sorts are deterministic', () async {
    final catalog = await const BundledSource().load();
    final ascending = selectCollection(catalog, const CollectionState());
    final descending = selectCollection(
      catalog,
      const CollectionState(sort: CollectionSort.dateDesc),
    );
    final title = selectCollection(
      catalog,
      const CollectionState(sort: CollectionSort.titleAsc),
    );

    expect(ascending.first.year, lessThanOrEqualTo(ascending.last.year));
    expect(descending.first.year, greaterThanOrEqualTo(descending.last.year));
    expect(title, hasLength(14));
  });

  test('load more advances by six and reset keeps sort', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(collectionStateProvider.notifier);

    controller.setQuery('starry');
    controller.setSort(CollectionSort.titleDesc);
    controller.loadMore(14);
    expect(container.read(collectionStateProvider).shown, 12);
    controller.loadMore(14);
    expect(container.read(collectionStateProvider).shown, 14);
    controller.reset();

    final state = container.read(collectionStateProvider);
    expect(state.query, isEmpty);
    expect(state.shown, 6);
    expect(state.sort, CollectionSort.titleDesc);
  });

  test('query parameters round-trip through real collection URLs', () {
    const original = CollectionState(
      query: 'starry night',
      movementId: 'post-impressionism',
      sort: CollectionSort.titleDesc,
    );

    final restored = CollectionState.fromQuery(original.toQueryParameters());

    expect(restored.query, original.query);
    expect(restored.movementId, original.movementId);
    expect(restored.sort, original.sort);
    expect(restored.shown, 6);
  });
}
