import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:washij/data/models/museum_painting.dart';
import 'package:washij/state/hourly_painting_state.dart';

MuseumPainting painting(int n, {bool image = true}) => MuseumPainting(
  id: 'cma-$n',
  source: 'Cleveland Museum of Art',
  title: 'Work $n',
  titleArabic: 'عمل $n',
  artist: 'Artist',
  artistArabic: 'فنان',
  date: '',
  dateArabic: '',
  medium: '',
  mediumArabic: '',
  dimensions: '',
  origin: '',
  originArabic: '',
  credit: '',
  sourceUrl: 'https://www.clevelandart.org/art/$n',
  imageAsset: null,
  imageUrl: image
      ? 'https://openaccess-cdn.clevelandart.org/$n/image.jpg'
      : null,
  licence: 'CC0',
  descriptionArabic: 'وصف',
  translationStatus: 'test',
);

void main() {
  final all = [for (var i = 0; i < 40; i++) painting(i)];

  test('hour slot changes exactly on the hour', () {
    final a = hourSlot(DateTime.utc(2026, 10, 29, 10, 0, 0));
    expect(hourSlot(DateTime.utc(2026, 10, 29, 10, 59, 59)), a);
    expect(hourSlot(DateTime.utc(2026, 10, 29, 11, 0, 0)), a + 1);
  });

  test('same hour gives the same painting', () {
    const state = HourlyPaintingState(slot: 500000);
    expect(
      pickHourlyPainting(all, state)!.id,
      pickHourlyPainting(all, state)!.id,
    );
  });

  test('refresh never repeats the previous painting', () {
    for (var slot = 0; slot < 50; slot++) {
      var previous = pickHourlyPainting(all, HourlyPaintingState(slot: slot))!;
      for (var nonce = 1; nonce < 5; nonce++) {
        final next = pickHourlyPainting(
          all,
          HourlyPaintingState(slot: slot, nonce: nonce),
        )!;
        expect(next.id, isNot(previous.id));
        previous = next;
      }
    }
  });

  test('paintings without an image are never picked', () {
    final mixed = [painting(1, image: false), painting(2)];
    for (var slot = 0; slot < 20; slot++) {
      expect(
        pickHourlyPainting(mixed, HourlyPaintingState(slot: slot))!.id,
        'cma-2',
      );
    }
    expect(
      pickHourlyPainting([
        painting(1, image: false),
      ], const HourlyPaintingState(slot: 1)),
      isNull,
    );
  });

  test('controller moves to the next hour on its own and resets refreshes', () {
    var now = DateTime.utc(2026, 10, 29, 10, 59, 59);
    final container = ProviderContainer(
      overrides: [hourlyClockProvider.overrideWithValue(() => now)],
    );
    addTearDown(container.dispose);
    final controller = container.read(
      hourlyPaintingControllerProvider.notifier,
    );
    final start = container.read(hourlyPaintingControllerProvider).slot;
    controller.refresh();
    expect(container.read(hourlyPaintingControllerProvider).nonce, 1);
    expect(container.read(hourlyPaintingControllerProvider).slot, start);
  });
}
