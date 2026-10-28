import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/artwork_page.dart';
import 'pages/cleveland_artwork_page.dart';
import 'pages/artist_page.dart';
import 'pages/artists_page.dart';
import 'pages/collection_page.dart';
import 'pages/home_page.dart';
import 'pages/movement_page.dart';
import 'pages/movements_page.dart';
import 'pages/museum_painting_page.dart';
import 'pages/not_found_page.dart';
import 'pages/readings_page.dart';
import 'widgets/shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => NotFoundPage(path: state.uri.path),
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            AppShell(path: state.uri.path, child: child),
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomePage()),
          GoRoute(
            path: '/artworks',
            builder: (context, state) =>
                CollectionPage(queryParameters: state.uri.queryParameters),
          ),
          GoRoute(
            path: '/artwork/cleveland/:id',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '');
              return id == null
                  ? NotFoundPage(path: state.uri.path)
                  : ClevelandArtworkPage(id: id);
            },
          ),
          GoRoute(
            path: '/artwork/museum/:id',
            builder: (context, state) =>
                MuseumPaintingPage(id: state.pathParameters['id'] ?? ''),
          ),
          GoRoute(
            path: '/artwork/:id',
            builder: (context, state) =>
                ArtworkPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/artists',
            builder: (context, state) => const ArtistsPage(),
          ),
          GoRoute(
            path: '/artist/:id',
            builder: (context, state) =>
                ArtistPage(id: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/movements',
            builder: (context, state) => const MovementsPage(),
          ),
          GoRoute(
            path: '/readings',
            builder: (context, state) => const ReadingsPage(),
          ),
          GoRoute(
            path: '/movement/:id',
            builder: (context, state) =>
                MovementPage(id: state.pathParameters['id']!),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
