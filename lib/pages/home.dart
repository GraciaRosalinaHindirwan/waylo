import 'package:flutter/material.dart';

import 'package:waylo/layouts/homeLayout.dart';
import 'package:waylo/components/searchBar.dart';
import 'package:waylo/components/quickAction.dart';
import 'package:waylo/components/recommendCard.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/repositories/destination_repository.dart';
import 'package:waylo/repositories/destination_repository_factory.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/pages/profile.dart';

import 'package:provider/provider.dart';
import 'package:waylo/service/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();
  final TextEditingController _searchController = TextEditingController();

  static const List<(String, String)> quickActions = [
    ('Beach', 'assets/img/beach.png'),
    ('Mountain', 'assets/img/mountain.png'),
    ('Nature', 'assets/img/nature.png'),
    ('Cultural', 'assets/img/cultural.png'),
    ('Historical', 'assets/img/historical.png'),
    ('Adventure', 'assets/img/adventure.png'),
  ];

  List<Destination> destinations = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    loadDestinations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadDestinations() async {
    final result = await _destinationRepository.getAllDestinations();
    if (!mounted) return;
    setState(() => destinations = result);
  }

  void openExplore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Explorepage()),
    );
  }

  List<Destination> get searchResults {
    final keyword = query.trim().toLowerCase();
    if (keyword.isEmpty) return [];

    return destinations.where((destination) {
      final location = destination.location;
      return destination.name.toLowerCase().contains(keyword) ||
          location.subdistrictName.toLowerCase().contains(keyword) ||
          location.districtName.toLowerCase().contains(keyword) ||
          location.provinceName.toLowerCase().contains(keyword);
    }).toList();
  }

  Widget buildDestinationCard(Destination destination) {
    final bannerImages = destination.images
        .where((image) => image.isBanner)
        .toList();

    final imageUrl = bannerImages.isNotEmpty
        ? bannerImages.first.imageUrl
        : null;

    return SizedBox(
      width: 196,
      height: 225,
      child: RecommendCard(
        image: imageUrl,
        name: destination.name,
        city: destination.location.districtName,
        rating: destination.rating,
        distance: '-',
        page: Detaildestination(destination: destination),
      ),
    );
  }

  Widget buildSearchResults() {
    final results = searchResults;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results',
          style: AppTextStyles.heading4.copyWith(color: Colors.black),
        ),
        const SizedBox(height: 16),
        if (results.isEmpty)
          Text(
            'Destinasi tidak ditemukan',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          )
        else
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: results.map(buildDestinationCard).toList(),
          ),
      ],
    );
  }

  Widget buildDefaultContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading4.copyWith(color: Colors.black),
        ),
        LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 16,
                children: quickActions
                    .map(
                      (item) => QuickAction(
                        label: item.$1,
                        icon: item.$2,
                        page: Explorepage(),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Destination Near You',
              style: AppTextStyles.heading4.copyWith(color: Colors.black),
            ),
            GestureDetector(
              onTap: openExplore,
              child: Text(
                'See All',
                style: AppTextStyles.body.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Row(
            spacing: 16,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: destinations.map(buildDestinationCard).toList(),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;
    final isSearching = query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Homelayout(
                  greeting: 'Hi,',
                  title: user?.fullname ?? 'Belum login',
                  subtitle: 'Discover your near Yogyakarta',
                  searchBar: Row(
                    children: [
                      Expanded(
                        child: CustomSearchBar(
                          controller: _searchController,
                          onChanged: (value) => setState(() => query = value),
                        ),
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
                          child: const Icon(Icons.tune_rounded, size: 22),
                        ),
                      ),
                    ],
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      isSearching
                          ? buildSearchResults()
                          : buildDefaultContent(),
                      const SizedBox(height: 119),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 16,
                  child: Image.asset(
                    'assets/img/waylo_AI.png',
                    width: 103,
                    height: 103,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),
          CustomBottomNavBar(
            currentIndex: 0,
            onTap: (index) {
              if (index == 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Explorepage()),
                );
              } else if (index == 2) {
                Navigator.pushReplacement(
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