
import 'package:flutter/material.dart';

class TreasureFoundCard extends StatelessWidget {
  final String imagePath;
  final String destinationName;
  final String description;
  final VoidCallback onContinue;

  const TreasureFoundCard({
    super.key,
    required this.imagePath,
    required this.destinationName,
    required this.description,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage = imagePath.startsWith('http');

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 36),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF3),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Destination image
            ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: double.infinity,
                height: 170,
                child: isNetworkImage
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _imagePlaceholder(),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _imagePlaceholder(),
                      ),
              ),
            ),

            const SizedBox(height: 14),

            // Treasure title
            const Text(
              '✦ Treasure Found! ✦',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17130F),
              ),
            ),

            const SizedBox(height: 4),

            // Destination name
            Text(
              destinationName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17130F),
              ),
            ),

            const SizedBox(height: 8),

            // Destination description
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: Color(0xFF81736B),
              ),
            ),

            const SizedBox(height: 14),

            // Continue button
            SizedBox(
              width: 180,
              height: 48,
              child: ElevatedButton(
                onPressed: onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFED8C59),
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shadowColor: Colors.black26,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'continue',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFE5EAF0),
      child: const Icon(
        Icons.landscape,
        size: 48,
        color: Color(0xFF8295A5),
      ),
    );
  }
}

/// Displays the treasure card as a centered game overlay.
Future<void> showTreasureFoundDialog({
  required BuildContext context,
  required String imagePath,
  required String destinationName,
  required String description,
  required VoidCallback onContinue,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (dialogContext) {
      return TreasureFoundCard(
        imagePath: imagePath,
        destinationName: destinationName,
        description: description,
        onContinue: () {
          Navigator.of(dialogContext).pop();
          onContinue();
        },
      );
    },
  );
}
