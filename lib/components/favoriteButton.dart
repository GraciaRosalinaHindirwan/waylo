
import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';

class FavoriteButton extends StatefulWidget {
  final bool initialFavorite;
  final Future<void> Function(bool isFavorite)? onChanged;

  const FavoriteButton({
    super.key,
    this.initialFavorite = false,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.initialFavorite;
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialFavorite != widget.initialFavorite) {
      isFavorite = widget.initialFavorite;
    }
  }

  Future<void> toggleFavorite() async {
    final previousFavorite = isFavorite;
    final nextFavorite = !previousFavorite;

    setState(() {
      isFavorite = nextFavorite;
    });

    try {
      await widget.onChanged?.call(nextFavorite);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isFavorite = previousFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: toggleFavorite,
        borderRadius: BorderRadius.circular(100),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 24,
                color: AppColors.accent,
              ),
              if (isFavorite) ...[
                const SizedBox(width: 8),
                const Text(
                  'Favorite',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
