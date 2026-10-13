
import 'package:flutter/material.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class PopularDestinationCard extends StatelessWidget {
  final Destination destination;
  final User user;
  final String? image;
  final String country;

  const PopularDestinationCard({
    super.key,
    required this.destination,
    required this.user,
    required this.image,
    required this.country,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detaildestination(
              destination: destination,
              user: user,
            ),
          ),
        );
      },
      child: Container(
        width: 120,
        height: 160,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            if (image != null && image!.isNotEmpty)
              Image(
                image: image!.startsWith('http')
                    ? NetworkImage(image!)
                    : AssetImage(image!) as ImageProvider,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.border,
                  );
                },
              )
            else
              Container(
                color: AppColors.border,
              ),

            // Gradient untuk membantu teks terbaca
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x00000000),
                    Color(0xCC000000),
                  ],
                  stops: [0.35, 0.55, 1.0],
                ),
              ),
            ),

            // Nama destinasi dan negara
            Positioned(
              left: 10,
              right: 8,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading4.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    country,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.white,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            // Tombol panah
            Positioned(
              right: 8,
              bottom: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFFB3261E),
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
