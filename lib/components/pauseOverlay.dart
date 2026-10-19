
import 'dart:ui';
import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  final bool isPaused;
  final VoidCallback onReplay;
  final VoidCallback onResume;

  const PauseOverlay({
    super.key,
    required this.isPaused,
    required this.onReplay,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    if (!isPaused) return const SizedBox.shrink();

    return Positioned.fill(
      child: Stack(
        children: [
          // Sedikit meredupkan background game
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.12),
            ),
          ),

          // Glass panel di tengah layar
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 12,
                  sigmaY: 12,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.48),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.75),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _PauseButton(
                        imagePath: 'assets/game/replay.png',
                        onTap: onReplay,
                      ),
                      const SizedBox(width: 22),
                      _PauseButton(
                        imagePath: 'assets/game/play.png',
                        onTap: onResume,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PauseButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _PauseButton({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 58,
          height: 58,
          child: Image.asset(
            imagePath,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.broken_image_outlined,
                color: Colors.red,
              );
            },
          ),
        ),
      ),
    );
  }
}
