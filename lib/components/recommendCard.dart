import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class RecommendCard extends StatelessWidget {
  final String? image;
  final String name;
  final String city;
  final double rating;
  final String distance;
  final Widget page;

  const RecommendCard({
    super.key,
    required this.image,
    required this.name,
    required this.city,
    required this.rating,
    required this.distance,
    required this.page,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        width: 196,
        height: 225,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16342B20),
              blurRadius: 20,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar destinasi
            Container(
              width: double.infinity,
              height: 130,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: AppColors.border,
                image: image != null && image!.isNotEmpty
                    ? DecorationImage(
                        image: image!.startsWith('http')
                            ? NetworkImage(image!)
                            : AssetImage(image!) as ImageProvider,
                        fit: BoxFit.cover,
                        onError: (exception, stackTrace) {
                          debugPrint('Gagal memuat gambar: $exception');
                        },
                      )
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xB71D1B18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 3,
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.white,
                          ),
                          Text(
                            distance,
                            style: AppTextStyles.label.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informasi destinasi dengan background card
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 13, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      color: const Color(0xFF25231F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: const Color(0xFF8A8781),
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: 4,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: Color(0xFFF37735),
                      ),
                      Text(
                        rating.toStringAsFixed(1),
                        style: AppTextStyles.label.copyWith(
                          color: const Color(0xFFF37735),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}