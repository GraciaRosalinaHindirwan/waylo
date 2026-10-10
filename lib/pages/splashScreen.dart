import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _waveController;
  late final AnimationController _logoController;

  bool _started = false;

  @override
  void initState() {
    super.initState();

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _startAnimation();
  }

  Future<void> _startAnimation() async {
    // Tahap 1: layar cream selama 1 detik.
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;
    setState(() => _started = true);

    // Tahap 2: animasi wave selama 2,5 detik.
    await _waveController.forward();

    if (!mounted) return;

    // Tahap 3: logo dan tagline muncul selama 1 detik.
    await _logoController.forward();

    if (!mounted) return;

    // Tunggu 800 ms setelah splash selesai.
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Pindah ke Login Page tanpa kembali ke splash.
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
  }

  @override
  void dispose() {
    _waveController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox.expand(
        child: !_started
            ? const ColoredBox(color: AppColors.background)
            : AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: WaveRevealPainter(progress: _waveController.value),
                    child: child,
                  );
                },
                child: Center(
                  child: FadeTransition(
                    opacity: CurvedAnimation(
                      parent: _logoController,
                      curve: Curves.easeOut,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          '../assets/img/logo.png',
                          width: 145,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'WAYLO',
                          style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Plan. Explore. Remember',
                          style: TextStyle(
                            fontFamily: 'Fraunces',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class WaveRevealPainter extends CustomPainter {
  final double progress;

  const WaveRevealPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Background biru.
    canvas.drawRect(Offset.zero & size, Paint()..color = AppColors.primary);

    if (progress >= 1) return;

    // Jarak vertikal ombak dibuat lebih besar.
    final amplitude = height * 0.22;

    final baseY = progress * (height + amplitude * 2) - amplitude * 1.5;

    // Profil ombak tidak simetris:
    // ada puncak tinggi, bukit pendek, dan lembah dalam.
    // Angka pertama adalah posisi X relatif,
    // angka kedua adalah ketinggian relatif.
    const profile = <Offset>[
      Offset(0.00, 0.78),
      Offset(0.04, 0.58),
      Offset(0.09, 0.84),
      Offset(0.14, 0.98),
      Offset(0.20, 0.91),
      Offset(0.27, 0.15),
      Offset(0.32, 0.08),
      Offset(0.37, 0.43),
      Offset(0.42, 0.77),
      Offset(0.46, 0.69),
      Offset(0.50, 0.87),
      Offset(0.56, 0.99),
      Offset(0.62, 0.75),
      Offset(0.68, 0.21),
      Offset(0.72, 0.27),
      Offset(0.76, 0.65),
      Offset(0.81, 0.58),
      Offset(0.85, 0.40),
      Offset(0.89, 0.73),
      Offset(0.93, 0.52),
      Offset(0.97, 0.81),
      Offset(1.00, 0.67),
    ];

    final points = profile.map((point) {
      return Offset(point.dx * width, baseY + (point.dy - 0.5) * amplitude * 2);
    }).toList();

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    // Bezier dengan titik kontrol yang lebih lembut.
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final dx = p1.dx - p0.dx;

      path.cubicTo(
        p0.dx + dx * 0.45,
        p0.dy,
        p1.dx - dx * 0.45,
        p1.dy,
        p1.dx,
        p1.dy,
      );
    }

    path
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..close();

    final opacity = ((1 - progress) / 0.08).clamp(0.0, 1.0).toDouble();

    canvas.drawPath(
      path,
      Paint()..color = AppColors.background.withOpacity(opacity),
    );
  }

  @override
  bool shouldRepaint(covariant WaveRevealPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
