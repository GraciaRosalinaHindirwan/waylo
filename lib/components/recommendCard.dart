import 'package:waylo/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class RecommendCard extends StatelessWidget {
  final String image;
  final String name;
  final String city;
  final String rating;
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 130,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(image),
                fit: BoxFit.cover,
              ),
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
                      crossAxisAlignment: CrossAxisAlignment.center,
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
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 13,
              left: 14,
              right: 14,
              bottom: 15,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body.copyWith(
                    color: const Color(0xFF25231F),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    city,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label.copyWith(
                      color: const Color(0xFF8A8781),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(top: 9),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 4,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 18,
                        color: Color(0xFFF37735),
                      ),
                      Text(
                        rating,
                        style: AppTextStyles.label.copyWith(
                          color: const Color(0xFFF37735),
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
    );
  }
}