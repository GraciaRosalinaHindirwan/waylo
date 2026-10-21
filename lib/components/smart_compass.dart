import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../theme/appColors.dart';

class SmartCompass extends StatefulWidget {
  const SmartCompass({super.key});

  @override
  State<SmartCompass> createState() => _SmartCompassState();
}

class _SmartCompassState extends State<SmartCompass> {
  StreamSubscription<MagnetometerEvent>? _magSubscription;
  StreamSubscription<AccelerometerEvent>? _accSubscription;

  AccelerometerEvent? _acceleration;
  double? _heading;

  @override
  void initState() {
    super.initState();

    _accSubscription = accelerometerEventStream().listen(
      (event) {
        _acceleration = event;
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );

    _magSubscription = magnetometerEventStream().listen(
      (event) {
        final acc = _acceleration;
        if (acc == null) return;

        final roll = math.atan2(acc.y, acc.z);
        final pitch = math.atan2(
          -acc.x,
          math.sqrt(acc.y * acc.y + acc.z * acc.z),
        );

        final x = event.x * math.cos(pitch) +
            event.z * math.sin(pitch);

        final y = event.x * math.sin(roll) *
                math.sin(pitch) +
            event.y * math.cos(roll) -
            event.z * math.sin(roll) *
                math.cos(pitch);

        final degrees =
            (math.atan2(-y, x) * 180 / math.pi + 360) %
                360;

        if (!mounted) return;

        setState(() {
          _heading = degrees;
        });
      },
      onError: (error) {
        debugPrint('Magnetometer error: $error');
      },
    );
  }

  @override
  void dispose() {
    _magSubscription?.cancel();
    _accSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Tooltip(
        message: heading == null
            ? 'Membaca kompas...'
            : 'Arah: ${heading.toStringAsFixed(0)}°',
        child: SizedBox(
          width: 46,
          height: 46,
          child: Center(
            child: heading == null
                ? const Icon(
                    Icons.explore_outlined,
                    color: AppColors.textSecondary,
                    size: 28,
                  )
                : Transform.rotate(
                    angle: -heading * math.pi / 180,
                    child: const Icon(
                      Icons.navigation_rounded,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
