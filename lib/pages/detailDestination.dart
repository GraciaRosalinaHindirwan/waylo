import 'package:flutter/material.dart';
import 'package:waylo/components/favoriteButton.dart';
import 'package:waylo/components/infoChip.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

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

  @override
  Widget build(BuildContext context) {
    final destination = widget.destination;
    final images = destination.images;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20), 
        child: SizedBox(
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
                      FavoriteButton(
                        onChanged: (isFavorite) {
                          debugPrint('Favorite: $isFavorite');
                        },
                      ),
                    ],
                  ),
                ),

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
              ],
            ),
          ),
        ),
      ),
    );
  }
}