
import 'package:flutter/material.dart';

class GameOverCard extends StatelessWidget {
  final int score;
  final VoidCallback onHome;
  final VoidCallback onReplay;

  const GameOverCard({
    super.key,
    required this.score,
    required this.onHome,
    required this.onReplay,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 290,
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF3),
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'POINTS',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              '$score',
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 60,
                fontWeight: FontWeight.w900,
                color: Color(0xFFBD201A),
                height: 1,
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GameOverButton(
                  imagePath: 'assets/game/home.png',
                  onTap: onHome,
                ),

                const SizedBox(width: 34),

                _GameOverButton(
                  imagePath: 'assets/game/replay.png',
                  onTap: onReplay,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GameOverButton extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const _GameOverButton({
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
            errorBuilder: (_, _, _) {
              return const Icon(
                Icons.image_not_supported_outlined,
                size: 32,
                color: Colors.red,
              );
            },
          ),
        ),
      ),
    );
  }
}
