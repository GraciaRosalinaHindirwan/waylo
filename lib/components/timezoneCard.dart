
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:waylo/models/timezone.dart';
import 'package:waylo/theme/appColors.dart';

class TimezoneCard extends StatefulWidget {
  final List<Timezone> timezones;
  final Timezone selectedTimezone;
  final ValueChanged<Timezone> onChanged;

  const TimezoneCard({
    super.key,
    required this.timezones,
    required this.selectedTimezone,
    required this.onChanged,
  });

  @override
  State<TimezoneCard> createState() => _TimezoneCardState();
}

class _TimezoneCardState extends State<TimezoneCard> {
  late Timezone selectedTimezone;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    selectedTimezone = widget.selectedTimezone;

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(covariant TimezoneCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedTimezone != widget.selectedTimezone) {
      selectedTimezone = widget.selectedTimezone;
    }
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  String get currentTime {
    final location = tz.getLocation(
      selectedTimezone.timeZoneId,
    );

    final now = tz.TZDateTime.now(location);

    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String get timeDifference {
    final location = tz.getLocation(
      selectedTimezone.timeZoneId,
    );

    final cityOffset =
        tz.TZDateTime.now(location).timeZoneOffset;

    final localOffset = DateTime.now().timeZoneOffset;

    final difference = cityOffset - localOffset;
    final totalMinutes = difference.inMinutes.abs();

    if (totalMinutes == 0) {
      return 'Same time';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    final direction =
        difference.isNegative ? 'behind' : 'ahead';

    final parts = <String>[];

    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hr' : 'hrs'}');
    }

    if (minutes > 0) {
      parts.add('$minutes min');
    }

    return '${parts.join(' ')} $direction';
  }

  Future<void> selectTimezone() async {
    final result = await showModalBottomSheet<Timezone>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(
              vertical: 12,
            ),
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select City',
                  style: TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...widget.timezones.map((timezone) {
                return ListTile(
                  title: Text(
                    timezone.cityName,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: AppColors.textPrimary,
                    ),
                  ),
                  trailing:
                      timezone.timeZoneId ==
                              selectedTimezone.timeZoneId
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.secondary,
                            )
                          : null,
                  onTap: () {
                    Navigator.pop(context, timezone);
                  },
                );
              }),
            ],
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() {
        selectedTimezone = result;
      });

      widget.onChanged(result);
    }
  }

  
@override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            // KONTEN CARD
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                selectedTimezone.cityName,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontFamily: 'Fraunces',
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: selectTimezone,
                              child: const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 30,
                                color: Color(0xFFF5AD66),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeDifference,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    currentTime,
                    style: const TextStyle(
                      fontFamily: 'Fraunces',
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // INNER SHADOW BAGIAN ATAS
            Positioned(
              top: 1,
              left: 1,
              right: 1,
              height: 12,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(27),
                      topRight: Radius.circular(27),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.12),
                        Colors.black.withOpacity(0.04),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.35, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
