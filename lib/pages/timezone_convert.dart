import 'package:flutter/material.dart';

import 'package:waylo/layouts/subPageLayout.dart';
import 'package:waylo/models/timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:waylo/repositories/timezone_repository_factory.dart';
import 'package:waylo/components/timezoneCard.dart';
import 'package:waylo/components/JakartaTimeConvert.dart';

class TimezoneConvert extends StatefulWidget {
  const TimezoneConvert({super.key});

  @override
  State<TimezoneConvert> createState() =>
      _TimezoneConvertState();
}

class _TimezoneConvertState extends State<TimezoneConvert> {
  final repository = TimezoneRepositoryFactory.create();

  List<Timezone> timezones = [];
  List<Timezone?> selectedTimezones = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadTimezones();
  }

  Future<void> loadTimezones() async {
    try {
      final result = await repository.getTimezones();

      if (!mounted) return;

      // Filter zona waktu yang valid di database timezone.
      final availableTimezones = result.where((timezone) {
        try {
          tz.getLocation(timezone.timeZoneId);
          return timezone.timeZoneId != 'Asia/Jakarta';
        } catch (_) {
          return false;
        }
      }).toList();

      Timezone? findTimezone(String id) {
        for (final timezone in availableTimezones) {
          if (timezone.timeZoneId == id) {
            return timezone;
          }
        }
        return null;
      }

      final selected = <Timezone?>[
        findTimezone('Asia/Tokyo'),
        findTimezone('Asia/Seoul'),
        findTimezone('Europe/London'),
      ];

      // Isi pilihan yang tidak tersedia dengan zona waktu valid
      // yang belum dipakai oleh card lainnya.
      for (var i = 0; i < selected.length; i++) {
        if (selected[i] == null) {
          for (final timezone in availableTimezones) {
            final alreadyUsed = selected.any(
              (item) => item?.timeZoneId == timezone.timeZoneId,
            );

            if (!alreadyUsed) {
              selected[i] = timezone;
              break;
            }
          }
        }
      }

      if (!mounted) return;

      setState(() {
        timezones = availableTimezones;
        selectedTimezones = selected;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return SubPageLayout(
      title: 'Time Convert',
      content: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Gagal memuat zona waktu',
                        ),
                        const SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isLoading = true;
                              errorMessage = null;
                            });

                            loadTimezones();
                          },
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : timezones.isEmpty ||
                selectedTimezones.isEmpty ||
                selectedTimezones.every(
                  (timezone) => timezone == null,
                )
                ? const Center(
                    child: Text(
                      'Zona waktu tidak tersedia',
                    ),
                  )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        // Card waktu Jakarta
                        const JakartaTimezoneCard(),

                        const SizedBox(height: 12),

                        // Kota tujuan pertama
                        if (selectedTimezones[0] != null)
                          TimezoneCard(
                            key: const ValueKey('timezone_1'),
                            timezones: timezones,
                            selectedTimezone: selectedTimezones[0]!,
                            onChanged: (timezone) {
                              setState(() {
                                selectedTimezones[0] = timezone;
                              });
                            },
                          ),

                        const SizedBox(height: 24),

                        // Kota tujuan kedua
                        if (selectedTimezones[1] != null)
                          TimezoneCard(
                            key: const ValueKey('timezone_2'),
                            timezones: timezones,
                            selectedTimezone: selectedTimezones[1]!,
                            onChanged: (timezone) {
                              setState(() {
                                selectedTimezones[1] = timezone;
                              });
                            },
                          ),

                        const SizedBox(height: 24),

                        // Kota tujuan ketiga
                        if (selectedTimezones[2] != null)
                          TimezoneCard(
                            key: const ValueKey('timezone_3'),
                            timezones: timezones,
                            selectedTimezone: selectedTimezones[2]!,
                            onChanged: (timezone) {
                              setState(() {
                                selectedTimezones[2] = timezone;
                              });
                            },
                          ),
                      ],
                    ),
    );
  }
}