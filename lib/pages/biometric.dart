
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class BiometricLoginSheet extends StatefulWidget {
  const BiometricLoginSheet({super.key});

  @override
  State<BiometricLoginSheet> createState() =>
      _BiometricLoginSheetState();
}

class _BiometricLoginSheetState extends State<BiometricLoginSheet>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();

  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  bool _isAuthenticating = false;

  String _message = 'Tekan ikon sidik jari untuk memulai';

  @override
  void initState() {
    super.initState();

    // Inisialisasi controller animasi terlebih dahulu.
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animasi berdenyut saat menunggu autentikasi.
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    debugPrint('BIOMETRIC: ikon fingerprint ditekan');

    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _message = 'Memverifikasi biometrik...';
    });

    // Hentikan animasi berdenyut selama verifikasi.
    _animationController.stop();

    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();

      debugPrint('BIOMETRIC: canCheckBiometrics = $canCheck');
      debugPrint('BIOMETRIC: isDeviceSupported = $isSupported');

      if (!canCheck && !isSupported) {
        throw Exception('Perangkat tidak mendukung biometrik.');
      }

      final biometrics = await _auth.getAvailableBiometrics();

      debugPrint('BIOMETRIC: available = $biometrics');

      if (biometrics.isEmpty) {
        throw Exception(
          'Sidik jari belum terdaftar di pengaturan perangkat.',
        );
      }

      final authenticated = await _auth.authenticate(
        localizedReason:
            'Verifikasi identitas untuk masuk ke WAYLO',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      debugPrint('BIOMETRIC: authenticated = $authenticated');

      if (!mounted) return;

      if (authenticated) {
        setState(() {
          _message = 'Sidik jari berhasil diverifikasi!';
        });

        await Future<void>.delayed(
          const Duration(milliseconds: 500),
        );

        if (!mounted) return;
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _message = 'Verifikasi gagal. Silakan coba lagi.';
        });

        _animationController.repeat(reverse: true);
      }
    } catch (e, stackTrace) {
      debugPrint('BIOMETRIC ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _message = e
            .toString()
            .replaceFirst('Exception: ', '');
      });

      _animationController.repeat(reverse: true);
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'WAYLO',
              style: TextStyle(
                fontFamily: 'Fraunces',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Finger Print WAYLO',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isAuthenticating
                    ? null
                    : () {
                        Navigator.of(context).pop(false);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.secondary,
                  shape: const StadiumBorder(),
                ),
                child: Text(
                  'Cancel',
                  style: AppTextStyles.button.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Text(
                _message,
                key: ValueKey(_message),
                textAlign: TextAlign.center,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: _isAuthenticating ? null : _authenticate,
              child: AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _isAuthenticating
                        ? 1.0
                        : _scaleAnimation.value,
                    child: child,
                  );
                },
                child: Icon(
                  Icons.fingerprint,
                  size: 76,
                  color: _isAuthenticating
                      ? AppColors.primary
                      : AppColors.secondaryLight,
                ),
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
