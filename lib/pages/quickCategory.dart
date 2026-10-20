import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waylo/service/auth_service.dart';

import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/profile.dart';
import 'package:waylo/repositories/destination/destination_repository.dart';
import 'package:waylo/repositories/destination/destination_repository_factory.dart';
import 'package:waylo/repositories/favorite/favorite_repository.dart';
import 'package:waylo/repositories/favorite/favorite_repository_factory.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class QuickCategoryPage extends StatefulWidget {
  final String category;

  const QuickCategoryPage({
    super.key,
    required this.category,
  });

  @override
  State<QuickCategoryPage> createState() => _QuickCategoryPageState();
}

class _QuickCategoryPageState extends State<QuickCategoryPage> {
  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();

  late final FavoriteRepository _favoriteRepository;

  List<Destination> destinations = [];
  Set<int> favoriteIds = {};
  final Set<int> updatingFavoriteIds = {};

  bool isLoading = true;
  bool isFavoriteLoading = true;

  @override
  void initState() {
    super.initState();
    loadDestinations();
    final authService = Provider.of<AuthService>(
      context,
      listen: false,
    );

    final userId = authService.currentUser?.id;

    if (userId == null) {
      throw Exception('Sesi user tidak ditemukan.');
    }

    _favoriteRepository = FavoriteRepositoryFactory.create(
      userId: userId,
    );
  }

  Future<void> loadDestinations() async {
    try {
      final all = await _destinationRepository.getAllDestinations();

      final filtered = all.where((destination) {
        return destination.categories.any(
          (category) =>
              category.name.trim().toLowerCase() ==
              widget.category.trim().toLowerCase(),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        destinations = filtered;
        isLoading = false;
      });

      await loadFavoriteIds();
    } catch (e, stackTrace) {
      debugPrint('Gagal memuat kategori: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        isLoading = false;
        isFavoriteLoading = false;
      });
    }
  }

  Future<void> loadFavoriteIds() async {
    try {
      final ids = await _favoriteRepository.getFavoriteIds();

      if (!mounted) return;

      setState(() {
        favoriteIds = ids.toSet();
        isFavoriteLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal memuat favorite: $e');

      if (!mounted) return;

      setState(() {
        isFavoriteLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat favorite: $e'),
        ),
      );
    }
  }

  Future<void> toggleFavorite(Destination destination) async {
    final destinationId = destination.id;

    // Cegah klik berulang ketika request masih berjalan.
    if (updatingFavoriteIds.contains(destinationId)) return;

    final wasFavorite = favoriteIds.contains(destinationId);

    setState(() {
      updatingFavoriteIds.add(destinationId);

      // Update ikon secara langsung.
      if (wasFavorite) {
        favoriteIds.remove(destinationId);
      } else {
        favoriteIds.add(destinationId);
      }
    });

    try {
      if (wasFavorite) {
        await _favoriteRepository.removeFavorite(destinationId);
      } else {
        await _favoriteRepository.addFavorite(destinationId);
      }
    } catch (e) {
      // Jika gagal, kembalikan status sebelumnya.
      if (!mounted) return;

      setState(() {
        if (wasFavorite) {
          favoriteIds.add(destinationId);
        } else {
          favoriteIds.remove(destinationId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui favorite: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          updatingFavoriteIds.remove(destinationId);
        });
      }
    }
  }

  Widget buildImage(Destination destination) {
    final banners = destination.images.where((i) => i.isBanner).toList();
    final imageUrl = banners.isNotEmpty ? banners.first.imageUrl : null;

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
              errorBuilder: (context, error, stackTrace) => placeholder,
            ),
    );
  }

  Widget buildCard(Destination destination) {
    final isFavorited = favoriteIds.contains(destination.id);
    final isUpdating = updatingFavoriteIds.contains(destination.id);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                Detaildestination(destination: destination),
          ),
        );

        // Sinkronkan kembali jika favorite berubah di halaman detail.
        if (mounted) {
          await loadFavoriteIds();
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
                    onTap: isUpdating
                        ? null
                        : () => toggleFavorite(destination),
                    child: Row(
                      spacing: 4,
                      children: [
                        Icon(
                          isFavorited
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 24,
                          color: AppColors.accent,
                        ),
                        Text(
                          isFavorited ? 'Favorited' : 'Add to Favorite',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (isUpdating)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
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
                    widget.category,
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
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
