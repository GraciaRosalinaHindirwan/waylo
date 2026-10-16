import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/profile.dart';
import 'package:waylo/repositories/destination_repository.dart';
import 'package:waylo/factories/destination_repository_factory.dart';
import 'package:waylo/repositories/favorite_repository.dart';
import 'package:waylo/repositories/favorite_repository_factory.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class QuickCategoryPage extends StatefulWidget {
  final String category;

  const QuickCategoryPage({super.key, required this.category});

  @override
  State<QuickCategoryPage> createState() => _QuickCategoryPageState();
}

class _QuickCategoryPageState extends State<QuickCategoryPage> {
  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();
  final FavoriteRepository _favoriteRepository =
      FavoriteRepositoryFactory.create();

  List<Destination> destinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDestinations();
  }

  Future<void> loadDestinations() async {
    final all = await _destinationRepository.getAllDestinations();
    final filtered = all
        .where(
          (destination) => destination.categories.any(
            (category) =>
                category.name.toLowerCase() == widget.category.toLowerCase(),
          ),
        )
        .toList();

    if (!mounted) return;
    setState(() {
      destinations = filtered;
      isLoading = false;
    });
  }

  Widget buildImage(Destination destination) {
    final banners = destination.images.where((i) => i.isBanner).toList();
    final imageUrl = banners.isNotEmpty ? banners.first.imageUrl : null;

    final placeholder = Container(
      width: 88,
      height: 88,
      color: AppColors.border,
      child: const Icon(Icons.image_outlined, color: AppColors.textSecondary),
    );

    return Container(
      width: 88,
      height: 88,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(width: 2, color: AppColors.border),
      ),
      child: imageUrl == null
          ? placeholder
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }

  Widget buildCard(Destination destination) {
    final isFavorited = _favoriteRepository.isFavorite(destination.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detaildestination(destination: destination),
          ),
        ).then((_) {
          if (mounted) setState(() {});
        });
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
            buildImage(destination),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          destination.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.heading4.copyWith(
                            color: Colors.black,
                          ),
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
                  Text(
                    '${destination.location.districtName}, ${destination.location.provinceName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _favoriteRepository.toggleFavorite(destination);
                      });
                    },
                    child: Row(
                      spacing: 4,
                      children: [
                        Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          size: 24,
                          color: AppColors.accent,
                        ),
                        Text(
                          isFavorited ? 'Favorited' : 'Add to Favorite',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 124,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 32,
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
                    widget.category,
                    style: AppTextStyles.heading3.copyWith(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : destinations.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada destinasi untuk kategori ini',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    itemCount: destinations.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) =>
                        buildCard(destinations[index]),
                  ),
          ),
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Explorepage()),
                  (route) => false,
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
