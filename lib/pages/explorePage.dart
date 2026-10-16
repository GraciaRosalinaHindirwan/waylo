import 'package:flutter/material.dart';
import 'package:waylo/components/infoChip.dart';
import 'package:waylo/service/location_service.dart';

import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/components/inspiringCard.dart';
import 'package:waylo/components/recommendCard.dart';
import 'package:waylo/components/searchBar.dart';
import 'package:waylo/layouts/homeLayout.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/repositories/destination_repository_factory.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/pages/profile.dart';

class Explorepage extends StatefulWidget {
  const Explorepage({super.key});

  @override
  State<Explorepage> createState() => _ExplorepageState();
}

class _ExplorepageState extends State<Explorepage> {
  late final Future<List<Destination>> _destinationsFuture;
  final LocationService _locationService = LocationService();
  String _currentCity = 'Mencari lokasi...';

  @override
  void initState() {
    super.initState();

    final repository = DestinationRepositoryFactory.create();
    _destinationsFuture = repository.getAllDestinations();

    _loadCurrentCity(); 
  }

  Future<void> _loadCurrentCity() async {
    try {
      final city = await _locationService.getCurrentCity();

      if (!mounted) return;

      setState(() {
        _currentCity = city;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _currentCity = 'Lokasi tidak tersedia';
      });

      debugPrint('Gagal mengambil lokasi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Homelayout(
      greeting: "Let's Find a Place",
      title: 'Explore',
      subtitle: 'Discover your next destination',
      bottomNavigationBar: CustomBottomNavBar(
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

      // Bagian ini saja yang menimpa gambar
      searchBar: Row(
        children: [
          const Expanded(child: CustomSearchBar()),
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
        children: [
          //destination near you
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destination Near You',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),

              TextButton(
                onPressed: () {
                  //diisi nanti sama page nya
                },
                child: Text(
                  'See All',
                  style: AppTextStyles.body.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerLeft,
            child: Infochip(
              icon: const Icon(
                Icons.near_me_rounded,
                size: 18,
                color: AppColors.secondaryLight,
              ),
              value: _currentCity,
              textColor: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 225,
            child: FutureBuilder<List<Destination>>(
              future: _destinationsFuture,
              builder: ((context, snapshot) {
                //loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                //error
                if (snapshot.hasError) {
                  return const Center(child: Text("Gagal memuat destinasi"));
                }

                //data berhasil diterima
                final destinations = snapshot.data ?? [];

                if (destinations.isEmpty) {
                  return const Center(child: Text("Belum ada destinasi"));
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: destinations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final destination = destinations[index];
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
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              Text(
                'Inspiring Destination',
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              ),

              TextButton(
                onPressed: () {
                  //diisi nanti sama page nya
                },
                child: Text(
                  'See All',
                  style: AppTextStyles.body.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),

          SizedBox(
            height: 160,
            child: FutureBuilder<List<Destination>>(
              future: _destinationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Gagal memuat destinasi'));
                }

                final destinations = snapshot.data ?? [];

                if (destinations.isEmpty) {
                  return const Center(child: Text('Belum ada destinasi'));
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: destinations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final destination = destinations[index];

                    final bannerImages = destination.images
                        .where((image) => image.isBanner)
                        .toList();

                    final imageUrl = bannerImages.isNotEmpty
                        ? bannerImages.first.imageUrl
                        : null;

                    return Inspiringcard(
                      destination: destination,
                      image: imageUrl,
                      location: destination.location.subdistrictName,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
