import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsetsGeometry.all(20), 
        child: SizedBox(
          width: double.infinity,
          height: 420, 
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
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

                Positioned(
                  top: 32,
                  left: 20,
                  child: Material(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}