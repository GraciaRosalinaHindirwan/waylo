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
  bool general = false;
  bool sound = false;
  bool vibrate = false;
  bool appUpdate = false;
  bool newService = false;

  bool loading = true;

  Widget _buildToggle({
    required String keyName,
    required bool value,
    required bool enabled,
  }) {
    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.45,
        child: _buildToggle(keyName: keyName, value: value, enabled: enabled),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      general = prefs.getBool('notif_general') ?? false;
      sound = prefs.getBool('notif_sound') ?? false;
      vibrate = prefs.getBool('notif_vibrate') ?? false;
      appUpdate = prefs.getBool('notif_update') ?? false;
      newService = prefs.getBool('notif_service') ?? false;
      loading = false;
    });

    await NotificationService.instance.updateSchedules();
  }

  Future<void> _changeSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();

    // Simpan status terbaru.
    await prefs.setBool(key, value);

    if (!mounted) return;

    setState(() {
      switch (key) {
        case 'notif_general':
          general = value;
          break;
        case 'notif_sound':
          sound = value;
          break;
        case 'notif_vibrate':
          vibrate = value;
          break;
        case 'notif_update':
          appUpdate = value;
          break;
        case 'notif_service':
          newService = value;
          break;
      }
    });

    if (!general) {
      await NotificationService.instance.cancelRecommendations();
    } else {
      await NotificationService.instance.updateSchedules();
    }
  }

  Widget _settingRow({
    required String title,
    required String keyName,
    required bool value,
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
              opacity: enabled ? 1.0 : 0.45,
              child: ToggleSwitch(
                // Gunakan key stabil agar state animasi toggle
                // tidak di-reset setiap kali halaman rebuild.
                key: ValueKey(keyName),
                onChanged: (newValue) {
                  _changeSetting(keyName, newValue);
                },
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
          // Background WAYLO.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/img/backgroundUp.jpg',
                width: double.infinity,
                fit: BoxFit.fitWidth,
                alignment: Alignment.bottomCenter,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Header.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 20, 34),
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

                // Pengaturan notifikasi.
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: [
                            _settingRow(
                              title: 'General Notification',
                              keyName: 'notif_general',
                              value: general,
                            ),
                            _settingRow(
                              title: 'Sound',
                              keyName: 'notif_sound',
                              value: sound,
                              enabled: general,
                            ),
                            _settingRow(
                              title: 'Vibrate',
                              keyName: 'notif_vibrate',
                              value: vibrate,
                              enabled: general,
                            ),
                            _settingRow(
                              title: 'App Update',
                              keyName: 'notif_update',
                              value: appUpdate,
                              enabled: general,
                            ),
                            _settingRow(
                              title: 'New Service Available',
                              keyName: 'notif_service',
                              value: newService,
                              enabled: general,
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom navigation yang sudah ada.
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          // Hubungkan dengan halaman Home dan Explore
          // sesuai konfigurasi navigasi WAYLO milikmu.
        },
      ),
    );
  }
}
