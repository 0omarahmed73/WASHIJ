import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/artwork.dart';

class HeroPagerState {
  const HeroPagerState({required this.artworkIds, this.index = 0});

  final List<String> artworkIds;
  final int index;
}

class HeroPager extends Notifier<HeroPagerState> {
  static const _initialIds = ['starry-night', 'great-wave', 'night-watch'];

  @override
  HeroPagerState build() => const HeroPagerState(artworkIds: _initialIds);

  void select(int index) => state = HeroPagerState(
    artworkIds: state.artworkIds,
    index: index.clamp(0, state.artworkIds.length - 1).toInt(),
  );

  void refresh(List<Artwork> artworks) {
    final current = state.artworkIds.toSet();
    final candidates =
        artworks
            .where(
              (artwork) =>
                  artwork.image != null && !current.contains(artwork.id),
            )
            .toList()
          ..shuffle(Random());
    if (candidates.length < 3) return;
    state = HeroPagerState(
      artworkIds: candidates.take(3).map((artwork) => artwork.id).toList(),
    );
  }
}

final heroPagerProvider = NotifierProvider<HeroPager, HeroPagerState>(
  HeroPager.new,
);
