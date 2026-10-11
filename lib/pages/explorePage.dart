
import 'package:flutter/material.dart';
import 'package:waylo/components/searchBar.dart';
import 'package:waylo/layouts/homeLayout.dart';
import 'package:waylo/theme/appColors.dart';

class Explorepage extends StatelessWidget {
  const Explorepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Homelayout(
      greeting: "Let's Find a Place",
      title: 'Explore',
      subtitle: 'Discover your next destination',
      content: Row(
        children: [
          const Expanded(
            child: CustomSearchBar(),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 54,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                // TODO: Buka halaman atau bottom sheet filter
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.card,
                elevation: 0,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Icon(
                Icons.tune_rounded,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
