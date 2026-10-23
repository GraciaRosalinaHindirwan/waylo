
import 'package:flutter/material.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/models/destinationImage.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;
  final VoidCallback? onTap;

  // Jarak opsional dari lokasi pengguna ke destinasi.
  final double? distanceKm;

  const DestinationCard({
    super.key,
    required this.destination,
    this.onTap,
    this.distanceKm,
  });

  // Mengambil gambar banner, atau gambar pertama jika banner tidak ada.
  DestinationImage? get _destinationImage {
    if (destination.images.isEmpty) return null;

    for (final image in destination.images) {
      if (image.isBanner) return image;
    }

    return destination.images.first;
  }

  // Mengambil nama lokasi untuk ditampilkan pada card.
  String get _locationName {
    final location = destination.location;

    if (location.districtName.trim().isNotEmpty) {
      return location.districtName;
    }

    return location.provinceName;
  }

  @override
  Widget build(BuildContext context) {
    final image = _destinationImage;

    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar destinasi dan badge jarak.
            AspectRatio(
              aspectRatio: 1.65,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (image != null && image.imageUrl.trim().isNotEmpty)
                    Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.secondary,
                            strokeWidth: 2,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return _imagePlaceholder();
                      },
                    )
                  else
                    _imagePlaceholder(),

                  if (distanceKm != null && distanceKm!.isFinite &&
                      distanceKm! >= 0)
                    Positioned(
                      left: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${distanceKm!.toStringAsFixed(1)} km away',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Nama, lokasi, dan rating.
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    destination.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _locationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        destination.rating.toStringAsFixed(1),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 12,
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w500,
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

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.border,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: AppColors.textSecondary,
        size: 32,
      ),
    );
  }
}
