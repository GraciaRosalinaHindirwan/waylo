import 'package:waylo/layouts/homeLayout.dart';
import 'package:waylo/components/searchBar.dart';
import 'package:waylo/components/quickAction.dart';
import 'package:waylo/components/recommendCard.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/repositories/destination_repository.dart';
import 'package:waylo/repositories/destination_repository_factory.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();

  static const List<(String, String)> quickActions = [
    ('Beach', 'assets/img/beach.png'),
    ('Mountain', 'assets/img/mountain.png'),
    ('Nature', 'assets/img/nature.png'),
    ('Cultural', 'assets/img/cultural.png'),
    ('Historical', 'assets/img/historical.png'),
    ('Adventure', 'assets/img/adventure.png'),
  ];

  List<Destination> destinations = [];

  @override
  void initState() {
    super.initState();
    loadDestinations();
  }

  Future<void> loadDestinations() async {
    final result = await _destinationRepository.getAllDestinations();
    if (!mounted) return;
    setState(() => destinations = result);
  }

  void openExplore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Explorepage(user: widget.user,)),
    );
  }

  String imagePath(Destination destination) {
    final fileName = destination.name.toLowerCase().replaceAll(' ', '_');
    return 'assets/img/$fileName.png';
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
        page: Detaildestination(
          destination: destination,
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Homelayout(
                  greeting: 'Hi,',
                  title: widget.user.fullname,
                  subtitle: 'Discover your near Yogyakarta',
                  searchBar: CustomSearchBar(
                    readOnly: true,
                    onTap: openExplore,
                  ),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Actions',
                        style: AppTextStyles.heading4.copyWith(
                          color: Colors.black,
                        ),
                      ),
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minWidth: constraints.maxWidth,
                            ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 16,
                              children: quickActions
                                  .map(
                                    (item) => QuickAction(
                                      label: item.$1,
                                      icon: item.$2,
                                      page: Explorepage(user: widget.user),
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
                            style: AppTextStyles.heading4.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          GestureDetector(
                            onTap: openExplore,
                            child: Text(
                              'See All',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accent,
                              ),
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
                          children: destinations
                              .map(buildDestinationCard)
                              .toList(),
                        ),
                      ),
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
                  MaterialPageRoute(builder: (context) => Explorepage(user: widget.user,)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}