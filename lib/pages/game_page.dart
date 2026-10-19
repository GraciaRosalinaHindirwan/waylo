import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../components/bird.dart';
import '../components/pauseOverlay.dart';
import '../components/gameOverCard.dart';
import '../components/cardTreasure.dart';
import '../models/destination.dart';
import '../service/destination_treasure_service.dart';

class WanderFlyGamePage extends StatefulWidget {
  final VoidCallback onHome;
  final String backgroundPath;
  final String birdUpPath;
  final String birdDownPath;
  final String coinPath;

  const WanderFlyGamePage({
    super.key,
    required this.onHome,
    required this.backgroundPath,
    required this.birdUpPath,
    required this.birdDownPath,
    required this.coinPath,
  });

  @override
  State<WanderFlyGamePage> createState() => _WanderFlyGamePageState();
}

class _ObstaclePair {
  double x;
  double gapY;
  double gapHeight;
  double spacingAfter;
  double coinY;

  bool hasScored = false;
  bool hasCoin;
  bool coinCollected = false;

  _ObstaclePair({
    required this.x,
    required this.gapY,
    required this.gapHeight,
    required this.spacingAfter,
    required this.coinY,
    required this.hasCoin,
  });
}

class _WanderFlyGamePageState extends State<WanderFlyGamePage> {
  final Random _random = Random();
  final DestinationService _destinationService = DestinationService();

  // Background music.
  late final AudioPlayer _bgmPlayer = AudioPlayer();
  bool _bgmDisposed = false;

  Timer? _gameLoop;
  Size _gameSize = Size.zero;

  int score = 0;

  bool isPaused = false;
  bool isGameOver = false;
  bool _treasureShowing = false;

  double _birdY = 0;
  double _birdVelocity = 0;

  final List<_ObstaclePair> _obstacles = [];

  // Game speed and physics.
  static const double _gravity = 1500;
  static const double _jumpVelocity = -450;
  static const double _obstacleSpeed = 450;

  double get _birdSize => _gameSize.width * 0.12;

  // Bird position.
  double get _birdX => _gameSize.width * 0.23;

  // Obstacle dimensions.
  double get _obstacleWidth => _gameSize.width * 0.38;

  @override
  void initState() {
    super.initState();
    _startBgm();
  }

  // Start looping background music.

  Future<void> _startBgm() async {
    try {
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.45);

      if (!mounted || _bgmDisposed) return;

      await _bgmPlayer.play(
        AssetSource('../assets/game/(1)Across_the_Jade_Ridge.mp3'),
      );
    } catch (e) {
      debugPrint('Failed to play WanderFly BGM: $e');
    }
  }

  Future<void> _pauseBgm() async {
    if (_bgmDisposed) return;

    try {
      await _bgmPlayer.pause();
    } catch (e) {
      debugPrint('Failed to pause BGM: $e');
    }
  }

  Future<void> _resumeBgm() async {
    if (_bgmDisposed) return;

    try {
      await _bgmPlayer.resume();
    } catch (e) {
      debugPrint('Failed to resume BGM: $e');
    }
  }

  @override
  void dispose() {
    _gameLoop?.cancel();
    _bgmDisposed = true;
    _bgmPlayer.dispose();
    super.dispose();
  }

  void _startGameLoop() {
    if (_gameLoop != null) return;

    _gameLoop = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _updateGame(0.016),
    );
  }

  void _initializeGame(Size size) {
    _gameSize = size;

    _birdY = size.height * 0.40;
    _birdVelocity = 0;

    score = 0;
    isPaused = false;
    isGameOver = false;
    _treasureShowing = false;

    _obstacles
      ..clear()
      ..add(_createObstacle(size.width + 30));
  }

  _ObstaclePair _createObstacle(double x) {
    // Random gap height.
    final gapHeight = _gameSize.height * (0.24 + _random.nextDouble() * 0.10);

    final margin = _gameSize.height * 0.08;
    final minCenter = margin + gapHeight / 2;
    final maxCenter = _gameSize.height - margin - gapHeight / 2;

    final gapY = minCenter + _random.nextDouble() * (maxCenter - minCenter);

    // Random distance between obstacle pairs.
    final spacingAfter = _gameSize.width * (0.42 + _random.nextDouble() * 0.18);

    // Coin tidak muncul di setiap obstacle. Peluang kemunculannya 30%.
    final hasCoin = _random.nextDouble() < 0.30;

    // Posisi coin diacak di dalam celah obstacle, bukan selalu di tengah.
    // Beri jarak dari batas atas/bawah agar coin tetap mudah terlihat.
    final coinSize = _gameSize.width * 0.09;
    final gapTop = gapY - gapHeight / 2;
    final gapBottom = gapY + gapHeight / 2;
    final coinMargin = coinSize * 0.65;
    final minCoinY = gapTop + coinMargin;
    final maxCoinY = gapBottom - coinMargin;
    final coinY = minCoinY +
        _random.nextDouble() * max(0.0, maxCoinY - minCoinY);

    return _ObstaclePair(
      x: x,
      gapY: gapY,
      gapHeight: gapHeight,
      spacingAfter: spacingAfter,
      coinY: coinY,
      hasCoin: hasCoin,
    );
  }

  void _updateGame(double dt) {
    if (!mounted ||
        _gameSize == Size.zero ||
        isPaused ||
        isGameOver ||
        _treasureShowing) {
      return;
    }

    setState(() {
      _birdVelocity += _gravity * dt;
      _birdY += _birdVelocity * dt;

      for (final obstacle in _obstacles) {
        obstacle.x -= _obstacleSpeed * dt;

        if (!obstacle.hasScored && obstacle.x + _obstacleWidth < _birdX) {
          obstacle.hasScored = true;
          score++;
        }
      }

      _obstacles.removeWhere((obstacle) => obstacle.x + _obstacleWidth < 0);

      if (_obstacles.isEmpty ||
          _obstacles.last.x < _gameSize.width - _obstacles.last.spacingAfter) {
        _obstacles.add(_createObstacle(_gameSize.width + 30));
      }
    });

    _checkBoundaryCollision();

    if (!isGameOver && !_treasureShowing) {
      _checkObstacleCollision();
      _checkCoinCollision();
    }
  }

  void _checkBoundaryCollision() {
    if (_birdY < 0 || _birdY + _birdSize > _gameSize.height) {
      debugPrint(
        'GAME OVER: boundary | '
        'birdY=$_birdY | '
        'birdSize=$_birdSize | '
        'screenHeight=${_gameSize.height}',
      );
      _endGame();
    }
  }

  void _checkObstacleCollision() {
    // Slightly smaller hitbox for fairer gameplay.
    final insetX = _birdSize * 0.48;
    final insetY = _birdSize * 0.30;

    final birdRect = Rect.fromLTRB(
      _birdX + insetX,
      _birdY + insetY,
      _birdX + _birdSize - insetX,
      _birdY + _birdSize - insetY,
    );

    for (final obstacle in _obstacles) {
      final gapTop = obstacle.gapY - obstacle.gapHeight / 2;
      final gapBottom = obstacle.gapY + obstacle.gapHeight / 2;

      final bodyInset = _obstacleWidth * 0.20;
      final bodyLeft = obstacle.x + bodyInset;
      final bodyRight = obstacle.x + _obstacleWidth - bodyInset;

      final topBodyRect = Rect.fromLTRB(
        bodyLeft,
        0,
        bodyRight,
        max(0.0, gapTop),
      );

      final bottomBodyRect = Rect.fromLTRB(
        bodyLeft,
        gapBottom,
        bodyRight,
        _gameSize.height,
      );

      debugPrint(
        'GAME OVER: obstacle collision | '
        'birdRect=$birdRect | '
        'obstacleX=${obstacle.x} | '
        'gapTop=$gapTop | '
        'gapBottom=$gapBottom',
      );

      if (birdRect.overlaps(topBodyRect) || birdRect.overlaps(bottomBodyRect)) {
        _endGame();
        return;
      }
    }
  }

  void _checkCoinCollision() {
    for (final obstacle in _obstacles) {
      if (!obstacle.hasCoin || obstacle.coinCollected) {
        continue;
      }

      final coinSize = _gameSize.width * 0.09;

      final birdCenter = Offset(_birdX + _birdSize / 2, _birdY + _birdSize / 2);

      final coinCenter = Offset(
        obstacle.x + _obstacleWidth / 2,
        obstacle.coinY,
      );

      final distance = (birdCenter - coinCenter).distance;

      if (distance < (_birdSize + coinSize) / 2) {
        obstacle.coinCollected = true;
        _showTreasure();
        return;
      }
    }
  }

  void _tapGame() {
    if (isPaused || isGameOver || _treasureShowing || _gameSize == Size.zero) {
      return;
    }

    setState(() {
      _birdVelocity = _jumpVelocity;
    });
  }

  Future<void> _pauseGame() async {
    if (isGameOver || _treasureShowing) return;

    setState(() {
      isPaused = true;
    });

    await _pauseBgm();
  }

  Future<void> _resumeGame() async {
    if (isGameOver) return;

    setState(() {
      isPaused = false;
    });

    await _resumeBgm();
  }

  void _endGame() {
    if (isGameOver) return;

    setState(() {
      isGameOver = true;
    });

    _pauseBgm();
  }

  Future<void> _restartGame() async {
    if (_gameSize == Size.zero) return;

    setState(() {
      _initializeGame(_gameSize);
    });

    // Restart the music from the beginning.
    try {
      await _bgmPlayer.stop();

      if (!mounted || _bgmDisposed) return;

      await _startBgm();
    } catch (e) {
      debugPrint('Failed to restart BGM: $e');
    }
  }

  Future<void> _showTreasure() async {
    if (_treasureShowing || isGameOver) return;

    setState(() {
      _treasureShowing = true;
    });

    // Hentikan musik sementara card harta karun ditampilkan.
    await _pauseBgm();

    try {
      // Ambil destinasi dari repository/database Waylo, bukan data hardcoded.
      final Destination? destination =
          await _destinationService.getRandomDestination();

      if (!mounted) return;

      if (destination == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Belum ada destinasi yang tersedia.'),
          ),
        );
        setState(() {
          _treasureShowing = false;
        });
        if (!isPaused && !isGameOver) await _resumeBgm();
        return;
      }

      final imageUrl = _destinationService.getImageUrl(destination);

      await showTreasureFoundDialog(
        context: context,
        // Card menerima URL network atau path asset lokal.
        imagePath: imageUrl ?? '',
        destinationName: destination.name,
        description: destination.description.trim().isNotEmpty
            ? destination.description
            : 'Discover this destination with Waylo.',
        onContinue: () {
          if (!mounted) return;

          setState(() {
            _treasureShowing = false;
          });

          if (!isPaused && !isGameOver) {
            _resumeBgm();
          }
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Gagal memuat destinasi untuk treasure: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _treasureShowing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Destinasi gagal dimuat. Coba lagi nanti.'),
        ),
      );

      if (!isPaused && !isGameOver) await _resumeBgm();
    }
  }

  Widget _buildObstacle({required double height}) {
    return SizedBox(
      width: _obstacleWidth,
      height: height,
      child: Image.asset(
        '../assets/game/obstacle_body.png',
        fit: BoxFit.fill,
        filterQuality: FilterQuality.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);

          if (_gameSize != size) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || _gameSize == size) return;

              setState(() {
                _initializeGame(size);
              });

              _startGameLoop();
            });
          }

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tapGame,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // Background.
                Positioned.fill(
                  child: Image.asset(
                    widget.backgroundPath,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),

                // Obstacles and coins.
                if (_gameSize != Size.zero)
                  ..._obstacles.map((obstacle) {
                    final gapTop = obstacle.gapY - obstacle.gapHeight / 2;

                    final gapBottom = obstacle.gapY + obstacle.gapHeight / 2;

                    final topHeight = max(0.0, gapTop);
                    final bottomHeight = max(0.0, size.height - gapBottom);

                    return Positioned.fill(
                      child: Stack(
                        clipBehavior: Clip.hardEdge,
                        children: [
                          // Top obstacle.
                          Positioned(
                            left: obstacle.x,
                            top: 0,
                            width: _obstacleWidth,
                            height: topHeight,
                            child: _buildObstacle(height: topHeight),
                          ),

                          // Bottom obstacle.
                          Positioned(
                            left: obstacle.x,
                            top: gapBottom,
                            width: _obstacleWidth,
                            height: bottomHeight,
                            child: _buildObstacle(height: bottomHeight),
                          ),

                          // Coin.
                          if (obstacle.hasCoin && !obstacle.coinCollected)
                            Positioned(
                              left:
                                  obstacle.x +
                                  _obstacleWidth / 2 -
                                  size.width * 0.045,
                              top: obstacle.coinY - size.width * 0.045,
                              width: size.width * 0.09,
                              height: size.width * 0.09,
                              child: Image.asset(
                                widget.coinPath,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.none,
                              ),
                            ),
                        ],
                      ),
                    );
                  }),

                // Bird.
                if (_gameSize != Size.zero)
                  Positioned(
                    left: _birdX,
                    top: _birdY,
                    width: _birdSize,
                    height: _birdSize,
                    child: GoldenPheasant(
                      size: _birdSize,
                      animateWings: true,
                      idleBob: false,
                      isPaused: isPaused || isGameOver || _treasureShowing,
                    ),
                  ),

                // Score.
                Positioned(
                  top: 18,
                  left: 0,
                  right: 0,
                  child: IgnorePointer(
                    child: Text(
                      '$score',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black54, blurRadius: 5)],
                      ),
                    ),
                  ),
                ),

                // Pause button.
                if (!isGameOver)
                  Positioned(
                    top: 48,
                    left: 12,
                    width: 44,
                    height: 44,
                    child: GestureDetector(
                      onTap: _pauseGame,
                      child: Image.asset(
                        '../assets/game/pause.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                // Pause overlay.
                if (isPaused)
                  PauseOverlay(
                    isPaused: isPaused,
                    onReplay: _restartGame,
                    onResume: _resumeGame,
                  ),

                // Game over overlay.
                if (isGameOver)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.18),
                      child: GameOverCard(
                        score: score,
                        onHome: widget.onHome,
                        onReplay: _restartGame,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
