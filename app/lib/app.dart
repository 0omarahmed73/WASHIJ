import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';
import 'state/daily_reminder_state.dart';
import 'theme/tokens.dart';
import 'theme/theme.dart';
import 'widgets/night_splash.dart';

class WashijAppRoot extends StatefulWidget {
  const WashijAppRoot({super.key});

  @override
  State<WashijAppRoot> createState() => _WashijAppRootState();
}

class _WashijAppRootState extends State<WashijAppRoot> {
  late final Timer? _splashTimer;
  var _showSplash = true;

  @override
  void initState() {
    super.initState();
    _showSplash = !kIsWeb;
    if (!_showSplash) {
      _splashTimer = null;
      return;
    }
    final reducedMotion = WidgetsBinding
        .instance
        .platformDispatcher
        .accessibilityFeatures
        .disableAnimations;
    _splashTimer = Timer(
      Duration(milliseconds: reducedMotion ? 600 : 3300),
      () => setState(() => _showSplash = false),
    );
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ProviderScope(child: WashijApp(showSplash: _showSplash));
}

class WashijApp extends ConsumerStatefulWidget {
  const WashijApp({super.key, required this.showSplash});

  final bool showSplash;

  @override
  ConsumerState<WashijApp> createState() => _WashijAppState();
}

class _WashijAppState extends ConsumerState<WashijApp> {
  @override
  void initState() {
    super.initState();
    pendingNotificationArtworkId.addListener(_openPendingNotificationArtwork);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openPendingNotificationArtwork();
    });
  }

  @override
  void dispose() {
    pendingNotificationArtworkId.removeListener(
      _openPendingNotificationArtwork,
    );
    super.dispose();
  }

  void _openPendingNotificationArtwork() {
    final id = pendingNotificationArtworkId.value;
    if (id == null || id.isEmpty || !mounted) return;
    pendingNotificationArtworkId.value = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = ref.read(routerProvider);
      router.go('/');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final route = id.startsWith('museum:')
            ? '/artwork/museum/${Uri.encodeComponent(id.substring(7))}'
            : '/artwork/${Uri.encodeComponent(id)}';
        router.push(route);
      });
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'وَشيج | متحف الفن الرقمي',
    debugShowCheckedModeBanner: false,
    locale: const Locale('ar'),
    supportedLocales: const [Locale('ar'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    theme: washijTheme,
    darkTheme: washijTheme,
    themeMode: ThemeMode.dark,
    routerConfig: ref.watch(routerProvider),
    builder: (context, child) => Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: WashijColors.midnight,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: WashijColors.midnight,
          systemNavigationBarDividerColor: WashijColors.midnight,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            child ?? const SizedBox.shrink(),
            if (widget.showSplash) const WashijNightSplash(),
          ],
        ),
      ),
    ),
  );
}
