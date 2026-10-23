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
  StreamSubscription<AccelerometerEvent>? _accSubscription;
  StreamSubscription<MagnetometerEvent>? _magSubscription;

  AccelerometerEvent? _acceleration;

  double? _heading;
  String? _sensorError;

  static const double _smoothFactor = 0.2;

  @override
  void initState() {
    super.initState();
    _startSensors();
  }

  void _startSensors() {
    _accSubscription = accelerometerEventStream().listen(
      (event) {
        _acceleration = event;
      },
      onError: (Object error) {
        debugPrint('SmartCompass - Accelerometer error: $error');

        if (!mounted) return;

        setState(() {
          _sensorError = 'Accelerometer tidak tersedia';
        });
      },
    );

    _magSubscription = magnetometerEventStream().listen(
      (event) {
        final acc = _acceleration;

        if (acc == null) return;

        final calculatedHeading = _calculateHeading(
          acc.x,
          acc.y,
          acc.z,
          event.x,
          event.y,
          event.z,
        );

        debugPrint(
          'SmartCompass | '
          'ACC: (${acc.x.toStringAsFixed(2)}, '
          '${acc.y.toStringAsFixed(2)}, '
          '${acc.z.toStringAsFixed(2)}) | '
          'MAG: (${event.x.toStringAsFixed(2)}, '
          '${event.y.toStringAsFixed(2)}, '
          '${event.z.toStringAsFixed(2)}) | '
          'HEADING: $calculatedHeading',
        );

        if (calculatedHeading == null || !mounted) return;

        setState(() {
          _sensorError = null;

          if (_heading == null) {
            _heading = calculatedHeading;
          } else {
            _heading = _smoothHeading(
              _heading!,
              calculatedHeading,
              _smoothFactor,
            );
          }
        });
      },
      onError: (Object error) {
        debugPrint('SmartCompass - Magnetometer error: $error');

        if (!mounted) return;

        setState(() {
          _sensorError = 'Magnetometer tidak tersedia';
        });
      },
    );
  }

  /// Menghitung heading dari accelerometer dan magnetometer.
  double? _calculateHeading(
    double ax,
    double ay,
    double az,
    double mx,
    double my,
    double mz,
  ) {
    // Normalisasi vektor gravitasi.
    final gravityMagnitude = math.sqrt(ax * ax + ay * ay + az * az);

    if (gravityMagnitude < 0.1) return null;

    ax /= gravityMagnitude;
    ay /= gravityMagnitude;
    az /= gravityMagnitude;

    // Proyeksikan medan magnet ke bidang horizontal.
    final dot = mx * ax + my * ay + mz * az;

    final hx = mx - dot * ax;
    final hy = my - dot * ay;
    final hz = mz - dot * az;

    final horizontalMagnitude = math.sqrt(hx * hx + hy * hy + hz * hz);

    if (horizontalMagnitude < 0.000001) return null;

    // Heading awal berdasarkan medan magnet horizontal.
    final azimuth = math.atan2(hy, hx);

    final degrees = (azimuth * 180 / math.pi + 360) % 360;

    if (!degrees.isFinite) return null;

    return degrees;
  }

  /// Menghaluskan perubahan sudut, termasuk melewati 0°/360°.
  double _smoothHeading(double previous, double current, double factor) {
    final difference = ((current - previous + 540) % 360) - 180;

    return (previous + difference * factor + 360) % 360;
  }

  @override
  void dispose() {
    _accSubscription?.cancel();
    _magSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final heading = _heading;

    final tooltipMessage =
        _sensorError ??
        (heading == null
            ? 'Membaca sensor kompas...'
            : 'Arah: ${heading.toStringAsFixed(0)}°');

    return Container(
      width: 46,
      height: 46,
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
        message: tooltipMessage,
        child: Center(
          child: heading == null
              ? Icon(
                  _sensorError != null
                      ? Icons.explore_off_outlined
                      : Icons.explore_outlined,
                  color: _sensorError != null
                      ? AppColors.error
                      : AppColors.textSecondary,
                  size: 28,
                )
              : Transform.rotate(
                  angle: heading * math.pi / 180,
                  child: const Icon(
                    Icons.navigation_rounded,
                    color: AppColors.accent,
                    size: 28,
                  ),
                ),
        ),
      ),
    );
  }
}
