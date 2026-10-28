import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/museum_painting.dart';

/// Which painting the "painting of the hour" widget shows.
///
/// [slot] is the number of whole hours since the Unix epoch, so every visitor
/// sees the same painting within an hour. [nonce] counts manual refreshes in
/// the current hour and is reset when the hour changes.
class HourlyPaintingState {
  const HourlyPaintingState({required this.slot, this.nonce = 0});

  final int slot;
  final int nonce;
}

int hourSlot(DateTime now) =>
    now.toUtc().millisecondsSinceEpoch ~/ Duration.millisecondsPerHour;

/// Picks a painting with an image for the given state, deterministically.
/// A manual refresh (nonce > 0) never repeats the previous pick.
MuseumPainting? pickHourlyPainting(
  List<MuseumPainting> paintings,
  HourlyPaintingState state,
) {
  final withImage = paintings
      .where(
        (painting) => painting.imageAsset != null || painting.imageUrl != null,
      )
      .toList(growable: false);
  if (withImage.isEmpty) return null;
  final random = Random(state.slot * 1000003 + state.nonce * 7919);
  var pick = withImage[random.nextInt(withImage.length)];
  if (state.nonce > 0 && withImage.length > 1) {
    final previous = pickHourlyPainting(
      paintings,
      HourlyPaintingState(slot: state.slot, nonce: state.nonce - 1),
    );
    if (previous?.id == pick.id) {
      pick = withImage[(withImage.indexOf(pick) + 1) % withImage.length];
    }
  }
  return pick;
}

final hourlyClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

class HourlyPaintingController extends Notifier<HourlyPaintingState> {
  Timer? _timer;

  @override
  HourlyPaintingState build() {
    ref.onDispose(() => _timer?.cancel());
    final now = ref.read(hourlyClockProvider)();
    _scheduleNextHour(now);
    return HourlyPaintingState(slot: hourSlot(now));
  }

  void _scheduleNextHour(DateTime now) {
    _timer?.cancel();
    final nextHour = DateTime.fromMillisecondsSinceEpoch(
      (hourSlot(now) + 1) * Duration.millisecondsPerHour,
      isUtc: true,
    );
    _timer = Timer(nextHour.difference(now.toUtc()), () {
      final current = ref.read(hourlyClockProvider)();
      state = HourlyPaintingState(slot: hourSlot(current));
      _scheduleNextHour(current);
    });
  }

  /// Shows a different painting for the rest of this hour.
  void refresh() =>
      state = HourlyPaintingState(slot: state.slot, nonce: state.nonce + 1);
}

final hourlyPaintingControllerProvider =
    NotifierProvider<HourlyPaintingController, HourlyPaintingState>(
      HourlyPaintingController.new,
    );
