import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/appColors.dart';
import '../theme/app_text_styles.dart';
import '../components/toggleSwitch.dart';
import '../components/buttomNav.dart';
import '../services/notification_service.dart';
import 'home.dart';
import 'explorePage.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  static const String backgroundAsset = 'assets/img/backgroundDown.png';

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

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Memuat pengaturan notifikasi yang tersimpan.
  Future<void> _loadSettings() async {
    try {
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

      await NotificationService.instance.initialize();
      await NotificationService.instance.updateSchedules();
    } catch (e) {
      debugPrint('Gagal memuat pengaturan notifikasi: $e');

      if (mounted) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengaturan notifikasi gagal dimuat.')),
        );
      }
    }
  }

  // Menyimpan dan menerapkan perubahan pengaturan.
  Future<void> _changeSetting(String key, bool value) async {
    try {
      // Minta izin Android ketika notifikasi utama diaktifkan.
      if (key == 'notif_general' && value) {
        await NotificationService.instance.initialize();

        final allowed = await NotificationService.instance.requestPermission();

        if (!allowed) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin notifikasi belum diberikan. '
                'Periksa pengaturan aplikasi di Android.',
              ),
            ),
          );

          return;
        }
      }

      final prefs = await SharedPreferences.getInstance();
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

      if (key == 'notif_general' && !value) {
        // Batalkan seluruh notifikasi yang sudah dijadwalkan
        // atau sedang ditampilkan.
        await NotificationService.instance.cancelAllNotifications();
      } else {
        // Perbarui jadwal setelah pengaturan berubah.
        await NotificationService.instance.updateSchedules();
      }
    } catch (e) {
      debugPrint('Gagal mengubah pengaturan notifikasi: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan notifikasi gagal diperbarui.'),
          ),
        );
      }
    }
  }

  // Komponen baris pengaturan.
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
                key: ValueKey(keyName),
                value: value,
                onChanged: enabled
                    ? (newValue) {
                        _changeSetting(keyName, newValue);
                      }
                    : null,
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
          // Background bagian bawah halaman.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                NotificationPage.backgroundAsset,
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
                // Header halaman.
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

                // Daftar pengaturan.
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

                            const SizedBox(height: 24),

                            // button untuk mengirim notifikasi tes
                            // ElevatedButton.icon(
                            //   onPressed: () async {
                            //     try {
                            //       final service = NotificationService.instance;

                            //       await service.initialize();

                            //       final allowed = await service.requestPermission();

                            //       if (!context.mounted) return;

                            //       if (!allowed) {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           const SnackBar(
                            //             content: Text('Izin notifikasi belum diberikan.'),
                            //           ),
                            //         );
                            //         return;
                            //       }

                            //       if (!general) {
                            //         ScaffoldMessenger.of(context).showSnackBar(
                            //           const SnackBar(
                            //             content: Text(
                            //               'Aktifkan General Notification terlebih dahulu.',
                            //             ),
                            //           ),
                            //         );
                            //         return;
                            //       }

                            //       await service.showTestNotification();

                            //       if (!context.mounted) return;

                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         const SnackBar(
                            //           content: Text('Notifikasi tes sudah dikirim.'),
                            //         ),
                            //       );
                            //     } catch (e) {
                            //       debugPrint('Test notification error: $e');

                            //       if (!context.mounted) return;

                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text('Gagal mengirim notifikasi: $e'),
                            //         ),
                            //       );
                            //     }
                            //   },
                            //   icon: const Icon(Icons.notifications_active),
                            //   label: const Text('Test Notification'),
                            // ),

                            //test berjalan di background
                            // const SizedBox(height: 16),

                            // ElevatedButton.icon(
                            //   icon: const Icon(Icons.timer_outlined),
                            //   label: const Text('Test Background Notification'),
                            //   onPressed: () async {
                            //     try {
                            //       await NotificationService.instance
                            //           .scheduleTestInOneMinute();

                            //       if (!context.mounted) return;

                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         const SnackBar(
                            //           content: Text(
                            //             'Terjadwal! Tutup WAYLO dan tunggu sekitar 1 menit.',
                            //           ),
                            //         ),
                            //       );
                            //     } catch (e) {
                            //       if (!context.mounted) return;

                            //       ScaffoldMessenger.of(context).showSnackBar(
                            //         SnackBar(
                            //           content: Text('Gagal menjadwalkan: $e'),
                            //         ),
                            //       );
                            //     }
                            //   },
                            // ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),

      // Navigasi bawah.
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );
          } else if (index == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Explorepage()),
            );
          }
        },
      ),
    );
  }
}
