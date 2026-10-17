
import 'package:flutter/material.dart';

import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/profile.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

/// Halaman See All dari Home: Destination Near You.
class HomeSeeAllPage extends StatelessWidget {
  final List<Destination> destinations;

  const HomeSeeAllPage({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return DestinationSeeAllLayout(
      title: 'Destination Near You',
      destinations: destinations,
      currentIndex: 0,
    );
  }
}

/// Halaman See All dari Explore: Destination Near You.
class ExploreNearbySeeAllPage extends StatelessWidget {
  final List<Destination> destinations;

  const ExploreNearbySeeAllPage({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return DestinationSeeAllLayout(
      title: 'Destination Near You',
      destinations: destinations,
      currentIndex: 1,
    );
  }
}

/// Halaman See All dari Explore: Inspiring Destination.
class InspiringSeeAllPage extends StatelessWidget {
  final List<Destination> destinations;

  const InspiringSeeAllPage({
    super.key,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return DestinationSeeAllLayout(
      title: 'Inspiring Destination',
      destinations: destinations,
      currentIndex: 1,
    );
  }
}

/// Layout bersama yang mengikuti gaya FavoritePage.
class DestinationSeeAllLayout extends StatelessWidget {
  final String title;
  final List<Destination> destinations;
  final int currentIndex;

  const DestinationSeeAllLayout({
    super.key,
    required this.title,
    required this.destinations,
    required this.currentIndex,
  });

  Widget _buildImage(Destination destination) {
    final banners =
        destination.images.where((image) => image.isBanner).toList();

    final imageUrl = banners.isNotEmpty
        ? banners.first.imageUrl
        : null;

    final placeholder = Container(
      width: 88,
      height: 88,
      color: AppColors.border,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.textSecondary,
      ),
    );

    return Container(
      width: 88,
      height: 88,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          width: 2,
          color: AppColors.border,
        ),
      ),
      child: imageUrl == null
          ? placeholder
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return placeholder;
              },
            ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    Destination destination,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detaildestination(
              destination: destination,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3F000000),
              blurRadius: 4,
              offset: Offset(4, 4),
            ),
          ],
        ),
        child: Row(
          spacing: 16,
          children: [
            _buildImage(destination),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 5,
                children: [
                  Text(
                    destination.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading4.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    '${destination.location.districtName}, '
                    '${destination.location.provinceName}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 16,
                        color: AppColors.secondary,
                      ),
                      Text(
                        destination.rating.toStringAsFixed(1),
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTab(BuildContext context, int index) {
    if (index == currentIndex) {
      Navigator.pop(context);
      return;
    }

    Widget page;

    switch (index) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const Explorepage();
        break;
      default:
        page = const ProfilePage();
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header mengikuti FavoritePage.
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 124),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 24,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Daftar hanya berisi destinasi yang dikirim oleh
          // tombol See All yang membuka halaman ini.
          Expanded(
            child: destinations.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No destinations available yet.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      20,
                    ),
                    itemCount: destinations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCard(
                        context,
                        destinations[index],
                      );
                    },
                  ),
          ),

          CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => _navigateTab(context, index),
          ),
        ],
      ),
    );
  }
}
