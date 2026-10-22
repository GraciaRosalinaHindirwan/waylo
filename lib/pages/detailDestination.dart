import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:waylo/service/auth_service.dart';

import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/components/enteranceFeeCard.dart';
import 'package:waylo/components/favoriteButton.dart';
import 'package:waylo/components/infoChip.dart';
import 'package:waylo/components/map_card.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/profile.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/repositories/favorite/favorite_repository_factory.dart';
import 'package:waylo/repositories/badge/travel_badge_repository_factory.dart';
import 'package:waylo/service/session_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Detaildestination extends StatefulWidget{
  final Destination destination; 
  
  const Detaildestination({
    super.key, 
    required this.destination, 
  });

  @override
  State<Detaildestination> createState() => _DetaildestinationState();
}

class _DetaildestinationState extends State<Detaildestination> {
  final PageController _pageController = PageController(); 
  int _currentIndex = 0; 

   @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  late Future<bool> _favoriteStatusFuture;

  @override
  void initState() {
    super.initState();

    final authService = Provider.of<AuthService>(
      context,
      listen: false,
    );

    final userId = authService.currentUser?.id;

    if (userId == null) {
      _favoriteStatusFuture = Future.error(
        Exception('Sesi user tidak ditemukan.'),
      );
      return;
    }

    final favoriteRepository = FavoriteRepositoryFactory.create(
      userId: userId,
    );

    _favoriteStatusFuture = favoriteRepository.isFavorite(
      widget.destination.id,
    );

    _recordBadgeVisit();
  }

  //badge 
  Future<void> _recordBadgeVisit() async {
    debugPrint('=== RECORD BADGE VISIT DIPANGGIL ===');
    final authService = context.read<AuthService>();
    final userId = authService.currentUser?.id;

      debugPrint('USER ID: $userId');

    if (userId == null) {
      debugPrint('Badge visit dilewati: user belum login.');
      return;
    }

    final repository = TravelBadgeRepositoryFactory.create(
      Supabase.instance.client,
      SessionStorage(),
    );

    try {
       debugPrint('MULAI: mencatat ${widget.destination.name}');

      await repository.recordDestinationVisit(
        destinationId: widget.destination.id.toString(),
      );

      debugPrint(
        'Badge visit berhasil dicatat: ${widget.destination.name}',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'Gagal mencatat badge visit: $e',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }


  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final images = destination.images;
    final isBanner = images.isNotEmpty &&
      _currentIndex < images.length &&
      images[_currentIndex].isBanner;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsetsGeometry.all(20), 
          child: Column(
            children: [
              SizedBox(
              width: double.infinity,
              height: 420, 
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: images.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentIndex = index;
                          });
                        },
                        itemBuilder:(context, index){
                          final imageUrl = images[index].imageUrl;
                          if (imageUrl.startsWith('http')) {
                            return Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                            );
                          }
                          return Image.asset(
                            images[index].imageUrl, 
                            fit: BoxFit.cover,  
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 48,
                                ),
                              );
                            },
                          );
                        }
                      ),
                    ),
            
                    // Overlay gelap di bagian bawah foto
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 160,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.75),
                            ],
                          ),
                        ),
                      ),
                    ),
            
                    Positioned(
                      top: 32,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Button Back
                          Material(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(14),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const SizedBox(
                                width: 42,
                                height: 42,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
            
                          // Button Favorite
                          FutureBuilder<bool>(
                            future: _favoriteStatusFuture,
                            builder: (context, snapshot) {
                              return FavoriteButton(
                                initialFavorite: snapshot.data ?? false,
                                onChanged: (isFavorite) async {
                                  final authService = Provider.of<AuthService>(
                                    context,
                                    listen: false,
                                  );

                                  final userId = authService.currentUser?.id;

                                  if (userId == null) {
                                    throw Exception('Sesi user tidak ditemukan.');
                                  }

                                  final repository = FavoriteRepositoryFactory.create(
                                    userId: userId,
                                  );

                                  try {
                                    if (isFavorite) {
                                      await repository.addFavorite(widget.destination.id);
                                    } else {
                                      await repository.removeFavorite(widget.destination.id);
                                    }
                                  } catch (error) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Gagal memperbarui favorite: $error'),
                                      ),
                                    );

                                    rethrow;
                                  }
                                },
                              );
                            },
                          )
                        ],
                      ),
                    ),
            
                    if (isBanner)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                          destination.name,
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.card,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.6),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                          const SizedBox(height: 4),
                          Infochip(
                            icon: const Icon(
                              Icons.near_me_rounded,
                              size: 24,
                              color: AppColors.secondaryLight,
                            ),
                            value: 'Yogyakarta, Indonesia',
                            textColor: AppColors.textSecondary,
                          ),
            
                          const SizedBox(height: 8),
                          Infochip(
                            icon: const Icon(
                              Icons.star_rounded,
                              size: 24,
                              color: AppColors.secondary,
                            ),
                            value: destination.rating.toString(),
                            textColor: AppColors.textSecondary,
                          )
                        ],
                      ),
                    ),
            
                    // Dots indicator
                    if (images.length > 1)
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            images.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentIndex == index ? 18 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: _currentIndex == index
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(100),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        
              const SizedBox(height: 16), 
        
              EntranceFeeCard(
                fee: destination.fee.toString(),
                openingHour: destination.openingHour.toString(),
                closingHour: destination.closingHour.toString(),
              ),
        
              const SizedBox(height: 8),
        
              Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: destination.categories.map((category) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Infochip(
                          value: category.name,
                          textColor: AppColors.secondary,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
        
              const SizedBox(height: 16), 
        
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Description",
                    style: AppTextStyles.heading4.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
        
                  const SizedBox(height: 8),
        
                  SizedBox(
                    width: double.infinity,
                    child: Text(
                      destination.description,
                      textAlign: TextAlign.left,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  SizedBox(height: 16), 

                  MapCard(
                    latitude: destination.coordinate.latitude, 
                    longitude: destination.coordinate.longitude, 
                    destinationName: destination.name
                  ), 
                ],
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: SafeArea(
        top: false,
        child: CustomBottomNavBar(
          currentIndex: 1,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(),
                  ),
                );
                break;
              case 1:
                // Sudah berada di Explore
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(),
                  ),
                );
                break;
            }
          },
        ),
      ),
    );
  }
}