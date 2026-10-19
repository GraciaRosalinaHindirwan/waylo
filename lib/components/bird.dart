
import 'package:flutter/material.dart';

class GoldenPheasant extends StatefulWidget {
  final double size;
  final bool animateWings;
  final bool idleBob;
  final bool isPaused;

  const GoldenPheasant({
    super.key,
    this.size = 40,
    this.animateWings = true,
    this.idleBob = false,
    this.isPaused = false,
  });

  @override
  State<GoldenPheasant> createState() => _GoldenPheasantState();
}

class _GoldenPheasantState extends State<GoldenPheasant>
    with TickerProviderStateMixin {
  late final AnimationController _wingController;
  late final AnimationController _bobController;

  @override
  void initState() {
    super.initState();

    _wingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _syncAnimations();
  }

  void _syncAnimations() {
    // Sayap bergerak hanya ketika game aktif.
    if (widget.animateWings && !widget.isPaused) {
      _wingController.repeat(reverse: true);
    } else {
      _wingController.stop();
    }

    // Gerakan naik-turun kecil juga berhenti ketika pause.
    if (widget.idleBob && !widget.isPaused) {
      _bobController.repeat(reverse: true);
    } else {
      _bobController.stop();
    }
  }

  @override
  void didUpdateWidget(covariant GoldenPheasant oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.animateWings != widget.animateWings ||
        oldWidget.idleBob != widget.idleBob ||
        oldWidget.isPaused != widget.isPaused) {
      _syncAnimations();
    }
  }

  @override
  void dispose() {
    _wingController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _wingController,
        _bobController,
      ]),
      builder: (context, child) {
        final wingUp = _wingController.value < 0.5;

        final bobOffset = widget.idleBob
            ? -4.0 * _bobController.value
            : 0.0;

        return Transform.translate(
          offset: Offset(0, bobOffset),
          child: Image.asset(
            wingUp
                ? '../assets/game/birdUp.png'
                : '../assets/game/birdDown.png',
            width: widget.size,
            height: widget.size,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.none,
          ),
        );
      },
    );
  }
}
