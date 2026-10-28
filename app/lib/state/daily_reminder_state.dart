import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/catalog.dart';
import '../data/models/artwork.dart';
import '../data/models/museum_painting.dart';
import '../state/providers.dart';

final pendingNotificationArtworkId = ValueNotifier<String?>(null);

class DailyArtworkNotifications {
  DailyArtworkNotifications._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _firstId = 24000;
  static const _scheduledDays = 30;
  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily_artwork',
      'لوحة اليوم',
      channelDescription: 'لوحة فنية جديدة كل يوم من متحف وَشيج',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      icon: 'washij_notification',
    ),
    iOS: DarwinNotificationDetails(),
  );

  static Future<void> initialize() async {
    if (kIsWeb) return;
    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('washij_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _onNotificationResponse(launchDetails?.notificationResponse);
    }
  }

  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      return result ?? true;
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final result = await _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, sound: true);
      return result ?? false;
    }
    return false;
  }

  static void _onNotificationResponse(NotificationResponse? response) {
    pendingNotificationArtworkId.value = response?.payload;
  }

  static Future<void> schedule(
    Catalog catalog,
    List<MuseumPainting> museumPaintings,
    DailyReminderSettings settings,
  ) async {
    if (kIsWeb) return;
    final artworks = catalog.artworks
        .where((artwork) => artwork.image != null)
        .toList(growable: false);
    final translatedPaintings = museumPaintings
        .where(
          (painting) =>
              painting.imageAsset != null || painting.imageUrl != null,
        )
        .toList(growable: false);
    if (artworks.isEmpty && translatedPaintings.isEmpty) return;

    final now = tz.TZDateTime.now(tz.local);
    final today = DateTime.utc(now.year, now.month, now.day);
    final todayTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.time.hour,
      settings.time.minute,
    );
    final firstDayOffset = todayTime.isAfter(now) ? 0 : 1;

    await Future.wait([
      for (var i = 0; i < _scheduledDays; i++) _plugin.cancel(id: _firstId + i),
    ]);
    await Future.wait([
      for (var i = 0; i < _scheduledDays; i++)
        _scheduleOne(
          catalog,
          artworks,
          translatedPaintings,
          today.add(Duration(days: firstDayOffset + i)),
          settings.time,
          i,
        ),
    ]);
  }

  static Future<void> cancel() async {
    await Future.wait([
      for (var i = 0; i < _scheduledDays; i++) _plugin.cancel(id: _firstId + i),
    ]);
  }

  static Future<void> _scheduleOne(
    Catalog catalog,
    List<Artwork> catalogArtworks,
    List<MuseumPainting> museumPaintings,
    DateTime date,
    TimeOfDay time,
    int index,
  ) async {
    final dayNumber = DateTime.utc(
      date.year,
      date.month,
      date.day,
    ).difference(DateTime.utc(2025, 1, 1)).inDays;
    final useMuseumPainting =
        museumPaintings.isNotEmpty &&
        (catalogArtworks.isEmpty || dayNumber.isOdd);
    late final String payload;
    late final String title;
    late final String body;
    if (useMuseumPainting) {
      final painting =
          museumPaintings[(dayNumber ~/ 2) % museumPaintings.length];
      payload = 'museum:${painting.id}';
      title = 'لوحة اليوم: ${painting.titleArabic}';
      body = 'من رسم ${painting.artistArabic} · ${painting.sourceNameArabic}';
    } else {
      final artwork =
          catalogArtworks[(dayNumber ~/ 2) % catalogArtworks.length];
      final artist = catalog.artists[artwork.artistId];
      payload = artwork.id;
      title = 'لوحة اليوم: ${artwork.titleAr}';
      body = artist == null ? artwork.dateText : 'من رسم ${artist.nameAr}';
    }
    final scheduledDate = tz.TZDateTime(
      tz.local,
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    await _plugin.zonedSchedule(
      id: _firstId + index,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload,
    );
  }
}

@immutable
class DailyReminderSettings {
  const DailyReminderSettings({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;

  DailyReminderSettings copyWith({bool? enabled, TimeOfDay? time}) =>
      DailyReminderSettings(
        enabled: enabled ?? this.enabled,
        time: time ?? this.time,
      );
}

final dailyReminderProvider =
    AsyncNotifierProvider<DailyReminderController, DailyReminderSettings>(
      DailyReminderController.new,
    );

class DailyReminderController extends AsyncNotifier<DailyReminderSettings> {
  static const _enabledKey = 'daily_artwork_reminder_enabled';
  static const _hourKey = 'daily_artwork_reminder_hour';
  static const _minuteKey = 'daily_artwork_reminder_minute';

  @override
  Future<DailyReminderSettings> build() async {
    final preferences = await SharedPreferences.getInstance();
    ref.listen(catalogProvider, (previous, next) {
      final settings = state.value;
      final catalog = next.value;
      if (settings?.enabled == true && catalog != null) {
        unawaited(_schedule(catalog, settings!));
      }
    });
    final lifecycle = AppLifecycleListener(
      onResume: () {
        final settings = state.value;
        final catalog = ref.read(catalogProvider).value;
        if (settings?.enabled == true && catalog != null) {
          unawaited(_schedule(catalog, settings!));
        }
      },
    );
    ref.onDispose(lifecycle.dispose);
    final settings = DailyReminderSettings(
      enabled: preferences.getBool(_enabledKey) ?? false,
      time: TimeOfDay(
        hour: (preferences.getInt(_hourKey) ?? 9).clamp(0, 23).toInt(),
        minute: (preferences.getInt(_minuteKey) ?? 0).clamp(0, 59).toInt(),
      ),
    );
    final catalog = ref.read(catalogProvider).value;
    if (settings.enabled && catalog != null) {
      unawaited(_schedule(catalog, settings));
    }
    return settings;
  }

  Future<void> _schedule(
    Catalog catalog,
    DailyReminderSettings settings,
  ) async {
    final museumPaintings = await ref.read(museumPaintingsProvider.future);
    await DailyArtworkNotifications.schedule(
      catalog,
      museumPaintings,
      settings,
    );
  }

  Future<bool> setEnabled(bool enabled) async {
    final current = state.value;
    if (current == null) return false;
    if (enabled == current.enabled) return true;

    if (enabled) {
      try {
        if (!await DailyArtworkNotifications.requestPermission()) return false;
      } on Object {
        return false;
      }
    }
    final updated = current.copyWith(enabled: enabled);
    state = AsyncData(updated);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, enabled);
    if (!enabled) {
      await DailyArtworkNotifications.cancel();
      return true;
    }
    final catalog = ref.read(catalogProvider).value;
    if (catalog != null) {
      try {
        await _schedule(catalog, updated);
      } on Object {
        state = AsyncData(current);
        await preferences.setBool(_enabledKey, current.enabled);
        await DailyArtworkNotifications.cancel();
        return false;
      }
    }
    return true;
  }

  Future<void> setTime(TimeOfDay time) async {
    final current = state.value;
    if (current == null) return;
    final updated = current.copyWith(time: time);
    state = AsyncData(updated);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_hourKey, time.hour);
    await preferences.setInt(_minuteKey, time.minute);
    final catalog = ref.read(catalogProvider).value;
    if (updated.enabled && catalog != null) {
      try {
        await _schedule(catalog, updated);
      } on Object {
        state = AsyncData(current);
        await preferences.setInt(_hourKey, current.time.hour);
        await preferences.setInt(_minuteKey, current.time.minute);
      }
    }
  }
}
