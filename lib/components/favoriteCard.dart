import 'package:flutter/material.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/models/favoriteDestination.dart';

class FavoriteCard extends StatelessWidget {
  final FavoriteDestination destination;

  const FavoriteCard({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 5,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              destination.imageUrl,
              width: 180,
              height: 180,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 24),

          // CONTENT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination.name,
                  style: const TextStyle(
                    fontFamily: 'Fraunces',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  destination.location,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    const Icon(
                      Icons.favorite_rounded,
                      size: 40,
                      color: Colors.red,
                    ),

                    const SizedBox(width: 10),

                    const Text(
                      'Favorited',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RATING
          Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 34,
                    color: AppColors.secondary,
                  ),

                  const SizedBox(width: 5),

                  Text(
                    destination.rating.toString(),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}