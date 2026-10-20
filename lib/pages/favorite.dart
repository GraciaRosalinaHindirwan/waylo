
import 'package:flutter/material.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/repositories/destination/destination_repository.dart';
import 'package:waylo/repositories/destination/destination_repository_factory.dart';
import 'package:waylo/repositories/favorite/favorite_repository.dart';
import 'package:waylo/repositories/favorite/favorite_repository_factory.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  final FavoriteRepository _favoriteRepository =
      FavoriteRepositoryFactory.create();

  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();

  late Future<List<Destination>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = _loadFavorites();
  }

  Future<List<Destination>> _loadFavorites() async {
    final favoriteIds = await _favoriteRepository.getFavoriteIds();

    if (favoriteIds.isEmpty) {
      return [];
    }

    final destinations =
        await _destinationRepository.getAllDestinations();

    final destinationsById = {
      for (final destination in destinations)
        destination.id: destination,
    };

    return favoriteIds
        .map((id) => destinationsById[id])
        .whereType<Destination>()
        .toList();
  }

  void _refreshFavorites() {
    setState(() {
      _favoritesFuture = _loadFavorites();
    });
  }

  Widget buildImage(Destination destination) {
    final banners =
        destination.images.where((image) => image.isBanner).toList();

    final imageUrl =
        banners.isNotEmpty ? banners.first.imageUrl : null;

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
              errorBuilder: (context, error, stackTrace) =>
                  placeholder,
            ),
    );
  }

  Future<void> _removeFavorite(Destination destination) async {
    try {
      await _favoriteRepository.removeFavorite(destination.id);

      if (!mounted) return;

      _refreshFavorites();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus favorite: $error'),
        ),
      );
    }
  }

  Widget buildCard(Destination destination) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detaildestination(
              destination: destination,
            ),
          ),
        );

        if (mounted) {
          _refreshFavorites();
        }
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
                    '${destination.location.districtName}, '
                    '${destination.location.provinceName}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _removeFavorite(destination),
                    child: Row(
                      spacing: 4,
                      children: [
                        const Icon(
                          Icons.favorite,
                          size: 24,
                          color: AppColors.accent,
                        ),
                        Text(
                          'Favorited',
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

  Widget _buildFavoritesContent() {
    return FutureBuilder<List<Destination>>(
      future: _favoritesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gagal memuat favorite.',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _refreshFavorites,
                    child: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
          );
        }

        final favorites = snapshot.data ?? [];

        if (favorites.isEmpty) {
          return Center(
            child: Text(
              'Belum ada destinasi favorit',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          itemCount: favorites.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: 16),
          itemBuilder: (context, index) =>
              buildCard(favorites[index]),
        );
      },
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
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
                    'Favorite Place',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildFavoritesContent(),
          ),
          CustomBottomNavBar(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Explorepage(),
                  ),
                  (route) => false,
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}
