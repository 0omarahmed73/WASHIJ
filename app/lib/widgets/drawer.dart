import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../paint/wordmark.dart';
import '../state/daily_reminder_state.dart';
import '../theme/tokens.dart';
import 'focus_ring.dart';

class WashijDrawer extends ConsumerWidget {
  const WashijDrawer({super.key});

  static const _links = [
    ('/', 'الرئيسية'),
    ('/artworks', 'اللوحات'),
    ('/artists', 'الفنانون'),
    ('/movements', 'المدارس الفنية'),
    ('/readings', 'قراءات الفن'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reminder = ref.watch(dailyReminderProvider);
    final settings = reminder.value;
    final supportsScheduledReminders =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);

    return Drawer(
      width: 320,
      backgroundColor: WashijColors.deepBlue,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wordmark(symbolSize: 38, showEnglish: true),
                CloseButton(),
              ],
            ),
            const SizedBox(height: 32),
            for (final (location, label) in _links)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go(location);
                  },
                  style: TextButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                    foregroundColor: WashijColors.ivory,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: Text(label),
                ),
              ),
            if (supportsScheduledReminders) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              FocusRing(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeTrackColor: WashijColors.starYellow,
                  title: const Text('لوحة جديدة كل يوم'),
                  subtitle: Text(
                    settings == null
                        ? 'جارٍ تحميل الإعداد'
                        : 'تذكير يومي عند ${settings.time.format(context)}',
                    style: const TextStyle(color: WashijColors.mist),
                  ),
                  value: settings?.enabled ?? false,
                  onChanged: settings == null
                      ? null
                      : (enabled) async {
                          final allowed = await ref
                              .read(dailyReminderProvider.notifier)
                              .setEnabled(enabled);
                          if (!allowed && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('لم يُسمح بإشعارات وَشيج.'),
                              ),
                            );
                          }
                        },
                ),
              ),
              FocusRing(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule),
                  title: const Text('وقت التنبيه'),
                  subtitle: Text(
                    settings?.time.format(context) ?? '٩:٠٠ ص',
                    style: const TextStyle(color: WashijColors.mist),
                  ),
                  onTap: settings == null
                      ? null
                      : () async {
                          final selected = await showTimePicker(
                            context: context,
                            initialTime: settings.time,
                          );
                          if (selected != null) {
                            await ref
                                .read(dailyReminderProvider.notifier)
                                .setTime(selected);
                          }
                        },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
