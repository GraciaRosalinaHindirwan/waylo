import 'package:flutter/material.dart';

import '../components/bird.dart';
import 'game_page.dart';

class GameIntro extends StatefulWidget {
  final VoidCallback onStart;
  final String backgroundAsset;

  const GameIntro({
    super.key,
    required this.onStart,
    this.backgroundAsset = '../assets/game/background.png',
  });

  @override
  State<GameIntro> createState() => _GameIntroState();
}

class _GameIntroState extends State<GameIntro> {
  bool _isGameStarted = false;

  // Menyusun obstacle tanpa mengecilkan badan
  // menjadi tiang tipis.

  Widget _buildObstacle({
    required double width,
    required double height,
    required bool isTop,
  }) {
    final capHeight = width * 0.55;

    // Cap sedikit menimpa body agar tidak ada celah.
    final overlap = width * 0.08;
    final bodyHeight = (height - capHeight + overlap).clamp(0.0, height);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Body memanjang sampai masuk sedikit
          // ke bagian belakang cap.
          Positioned(
            left: 0,
            right: 0,
            top: isTop ? 0 : capHeight - overlap,
            bottom: isTop ? capHeight - overlap : 0,
            child: Image.asset(
              '../assets/game/obstacle_body.png',
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),

          // Cap menutupi ujung body.
          // Positioned(
          //   left: -width * 0.12,
          //   right: -width * 0.12,
          //   top: isTop ? null : 0,
          //   bottom: isTop ? 0 : null,
          //   height: capHeight + overlap,
          //   child: Transform(
          //     alignment: Alignment.center,
          //     transform: Matrix4.diagonal3Values(1, isTop ? 1 : -1, 1),
          //     child: Image.asset(
          //       'assets/game/obstacle_cap.png',
          //       fit: BoxFit.contain,
          //       filterQuality: FilterQuality.none,
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        final obstacleWidth = w * 0.30;
        final obstacleHeight = h * 0.46;

        return ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background.
              Image.asset(widget.backgroundAsset, fit: BoxFit.fill),
              // Tombol kembali ke Home.
Positioned(
  top: h * 0.04,
  left: w * 0.04,
  child: GestureDetector(
    onTap: () {
      Navigator.of(context).pop();
    },
    child: Container(
      width: w * 0.08,
      height: w * 0.08,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7).withOpacity(0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE6DCC8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const Icon(
        Icons.home_rounded,
        color: Color(0xFFE8753D),
        size: 20,
      ),
    ),
  ),
),

              Positioned(
                top: h * 0.12,
                left: w * 0.05,
                right: w * 0.05,
                child: Column(
                  children: [
                    Text(
                      'WAYBIRD',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: w * 0.105,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: const Color(0xFFFFD77A),
                        shadows: const [
                          Shadow(
                            color: Color(0xFF8B1E16),
                            offset: Offset(3, 4),
                            blurRadius: 0,
                          ),
                          Shadow(
                            color: Color(0xFF4A2118),
                            offset: Offset(2, 5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Obstacle atas.
              Positioned(
                top: 0,
                right: -w * 0.025,
                width: obstacleWidth,
                height: obstacleHeight,
                child: _buildObstacle(
                  width: obstacleWidth,
                  height: obstacleHeight,
                  isTop: true,
                ),
              ),

              // Obstacle bawah.
              Positioned(
                bottom: 0,
                right: w * 0.025,
                width: obstacleWidth,
                height: obstacleHeight,
                child: _buildObstacle(
                  width: obstacleWidth,
                  height: obstacleHeight,
                  isTop: false,
                ),
              ),

              // Burung.
              Positioned(
                left: w * 0.10,
                top: h * 0.39,
                child: GoldenPheasant(
                  size: w * 0.14,
                  animateWings: true,
                  idleBob: true,
                ),
              ),

              // Tombol Play.
              if (!_isGameStarted)
                Positioned(
                  left: w * 0.42,
                  top: h * 0.50,
                  width: w * 0.20,
                  height: w * 0.20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WanderFlyGamePage(
                            onHome: () {
                              Navigator.of(context).pop();
                            },
                            backgroundPath: '../assets/game/background.png',
                            birdUpPath: '../assets/game/birdUp.png',
                            birdDownPath: '../assets/game/birdDown.png',
                            coinPath: '../assets/game/coin.png',
                          ),
                        ),
                      );
                    },
                    child: Image.asset(
                      '../assets/game/play.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
