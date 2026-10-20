import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:waylo/service/destination_filter_service.dart';

import 'package:waylo/layouts/homeLayout.dart';
import 'package:waylo/components/customSearchBar.dart';
import 'package:waylo/components/quickAction.dart';
import 'package:waylo/components/recommendCard.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/repositories/destination/destination_repository.dart';
import 'package:waylo/repositories/destination/destination_repository_factory.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/pages/profile.dart';
import 'package:waylo/pages/quickCategory.dart';
import 'package:provider/provider.dart';
import 'package:waylo/service/auth_service.dart';

import 'package:waylo/pages/seeAllPage.dart';
import 'package:waylo/pages/game_intro.dart';
import 'package:waylo/pages/aiRecommendation.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DestinationRepository _destinationRepository =
      DestinationRepositoryFactory.create();

  final DestinationFilterService _filterService = DestinationFilterService();
  Position? _userPosition;
  bool _loadingNearby = true;

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
    _loadUserPosition();
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
        distance: getDistance(destination),
        page: Detaildestination(destination: destination),
      ),
    );
  }

  Future<void> _loadUserPosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        debugPrint('Location service tidak aktif');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        debugPrint('Izin lokasi ditolak: $permission');
        return;
      }

      final position = await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        _userPosition = position;
      });

      debugPrint(
        'Koordinat pengguna: '
        '${position.latitude}, ${position.longitude}',
      );
    } catch (e) {
      debugPrint('Gagal mengambil lokasi pengguna: $e');
    } finally {
      if (mounted) {
        setState(() {
          _loadingNearby = false;
        });
      }
    }
  }

  List<Destination> get nearbyDestinations {
    if (_userPosition == null) {
      return [];
    }

    return _filterService.getNearbyDestinations(
      destinations: destinations,
      userLatitude: _userPosition!.latitude,
      userLongitude: _userPosition!.longitude,
      radiusInMeters: 10000,
    );
  }

  String getDistance(Destination destination) {
    if (_userPosition == null) return '-';

    final distanceInMeters = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      destination.coordinate.latitude,
      destination.coordinate.longitude,
    );

    return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthService>().currentUser;

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
                  searchBar: const CustomSearchBar(),
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
                                          page: QuickCategoryPage(
                                            category: item.$1,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 8),

                      // WayBi game banner — menyatu dengan warna dan gaya Home.
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => GameIntro(
                                onStart: () {
                                  debugPrint('WayBi game started');
                                },
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: double.infinity,
                          height: 142,
                          padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFFFFE8C8),
                                Color(0xFFFFD7B5),
                                Color(0xFFFFF1D9),
                              ],
                            ),
                            border: Border.all(
                              color: const Color(0xFFF4C49B),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFE99A65,
                                ).withOpacity(0.12),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.72),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'WAYLO MINI GAME',
                                        style: TextStyle(
                                          color: Color(0xFFB85B35),
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    const Text(
                                      'Fly with WayBi!',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF603B2B),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Collect coins and explore the sky',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Color(0xFF805B48),
                                        fontSize: 11,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE8753D),
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Play now',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                flex: 4,
                                child: Image.asset(
                                  'assets/img/waybi.png',
                                  height: 126,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.flutter_dash_rounded,
                                      size: 76,
                                      color: Color(0xFFE8753D),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeSeeAllPage(
                                    destinations: nearbyDestinations,
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'See All',
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.accent,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 265,
                        child: _loadingNearby
                            ? const Center(child: CircularProgressIndicator())
                            : _userPosition == null
                            ? const Center(
                                child: Text('Lokasi pengguna tidak tersedia'),
                              )
                            : nearbyDestinations.isEmpty
                            ? const Center(
                                child: Text(
                                  'Tidak ada destinasi dalam radius 10 km',
                                ),
                              )
                            : ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                itemCount: nearbyDestinations.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final destination = nearbyDestinations[index];
                                  return buildDestinationCard(destination);
                                },
                              ),
                      ),

                      const SizedBox(height: 119),
                    ],
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 16,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AiRecommendationPage()),
                      );
                    },
                    child: Image.asset(
                      'assets/img/waylo_AI.png',
                      width: 103,
                      height: 103,
                      fit: BoxFit.cover,
                    ),
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
