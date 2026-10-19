
import 'package:flutter/material.dart';

enum ObstacleDirection {
  top,
  bottom,
}

class ChineseObstacle extends StatelessWidget {
  final double width;
  final double height;
  final String bodyPath;
  final String capPath;
  final ObstacleDirection direction;

  const ChineseObstacle({
    super.key,
    required this.width,
    required this.height,
    required this.bodyPath,
    required this.capPath,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    // Tinggi cap mengikuti rasio gambar aslinya.
    // Sesuaikan rasio ini setelah memeriksa PNG final.
    final capHeight = width * 0.48;
    final actualCapHeight =
        capHeight.clamp(0.0, height);

    final isTop = direction == ObstacleDirection.top;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Badan obstacle.
          Positioned(
            left: 0,
            right: 0,
            top: isTop ? 0 : actualCapHeight,
            bottom: isTop ? actualCapHeight : 0,
            child: Image.asset(
              bodyPath,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),

          // Cap tetap memakai rasio ukuran yang sama.
          Positioned(
            left: 0,
            right: 0,
            top: isTop ? null : 0,
            bottom: isTop ? 0 : null,
            height: actualCapHeight,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(
                1,
                isTop ? 1 : -1,
                1,
              ),
              child: Image.asset(
                capPath,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
