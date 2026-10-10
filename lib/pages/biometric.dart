
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

class _BiometricLoginSheetState
    extends State<BiometricLoginSheet> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isAuthenticating = false;
  String _message = 'Sentuh sensor sidik jari';

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _message = 'Memverifikasi biometrik...';
    });

    try {
      final canAuthenticate =
          await _auth.canCheckBiometrics ||
          await _auth.isDeviceSupported();

      if (!mounted) return;

      if (!canAuthenticate) {
        setState(() {
          _message = 'Perangkat tidak mendukung biometrik';
        });
        return;
      }

      final biometrics = await _auth.getAvailableBiometrics();

      if (!mounted) return;

      if (biometrics.isEmpty) {
        setState(() {
          _message =
              'Daftarkan sidik jari di pengaturan perangkat';
        });
        return;
      }

      final authenticated = await _auth.authenticate(
        localizedReason: 'Verifikasi identitas untuk masuk ke Waylo',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) return;

      if (authenticated) {
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          _message = 'Verifikasi dibatalkan. Coba lagi.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _message = 'Gagal memverifikasi. Silakan coba lagi.';
      });
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
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shadowColor:
                      AppColors.textPrimary.withOpacity(0.25),
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

            Text(
              _message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 28),

            GestureDetector(
              onTap: _isAuthenticating ? null : _authenticate,
              child: Icon(
                Icons.fingerprint,
                size: 76,
                color: AppColors.secondaryLight,
              ),
            ),

            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}
