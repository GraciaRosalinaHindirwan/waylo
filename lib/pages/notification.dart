
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/appColors.dart';
import '../theme/app_text_styles.dart';
import '../components/toggleSwitch.dart';
import '../components/buttomNav.dart';
import '../services/notification_service.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool general = true;
  bool sound = true;
  bool vibrate = true;
  bool appUpdate = true;
  bool newService = true;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      general = prefs.getBool('notif_general') ?? true;
      sound = prefs.getBool('notif_sound') ?? true;
      vibrate = prefs.getBool('notif_vibrate') ?? true;
      appUpdate = prefs.getBool('notif_update') ?? true;
      newService = prefs.getBool('notif_service') ?? true;
      loading = false;
    });
  }

  Future<void> _changeSetting(
    String key,
    bool value,
    void Function(bool) update,
  ) async {
    update(value);
    setState(() {});

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);

    if (key == 'notif_general' && !value) {
      await NotificationService.instance.cancelRecommendations();
    } else {
      await NotificationService.instance.updateSchedules();
    }
  }

  Widget _settingRow({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontSize: 12,
                color: enabled
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !enabled,
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: ToggleSwitch(
                key: ValueKey(value),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/about_mobile_background.png',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                errorBuilder: (_, __, ___) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16, 22, 20, 34,
                  ),
                  child: Row(
                    children: [
                      Material(
                        color: AppColors.card,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () => Navigator.pop(context),
                          child: const SizedBox(
                            width: 32,
                            height: 32,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 17,
                              color: AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 22),
                      Text(
                        'Notification',
                        style: AppTextStyles.heading2.copyWith(
                          fontFamily: 'Fraunces',
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: loading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          children: [
                            _settingRow(
                              title: 'General Notification',
                              value: general,
                              onChanged: (v) => _changeSetting(
                                'notif_general',
                                v,
                                (value) => general = value,
                              ),
                            ),
                            _settingRow(
                              title: 'Sound',
                              value: sound,
                              enabled: general,
                              onChanged: (v) => _changeSetting(
                                'notif_sound',
                                v,
                                (value) => sound = value,
                              ),
                            ),
                            _settingRow(
                              title: 'Vibrate',
                              value: vibrate,
                              enabled: general,
                              onChanged: (v) => _changeSetting(
                                'notif_vibrate',
                                v,
                                (value) => vibrate = value,
                              ),
                            ),
                            _settingRow(
                              title: 'App Update',
                              value: appUpdate,
                              enabled: general,
                              onChanged: (v) => _changeSetting(
                                'notif_update',
                                v,
                                (value) => appUpdate = value,
                              ),
                            ),
                            _settingRow(
                              title: 'New Service Available',
                              value: newService,
                              enabled: general,
                              onChanged: (v) => _changeSetting(
                                'notif_service',
                                v,
                                (value) => newService = value,
                              ),
                            ),
                            const SizedBox(height: 20),
                            OutlinedButton.icon(
                              onPressed: () async {
                                final allowed =
                                    await NotificationService.instance
                                        .requestPermission();

                                if (!context.mounted) return;

                                if (allowed) {
                                  await NotificationService.instance
                                      .showTestNotification();
                                } else {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Izin notifikasi belum diberikan.',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.notifications_active),
                              label: const Text('Test notification'),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Hubungkan ke halaman Home dan Explore milikmu.
        },
      ),
    );
  }
}
