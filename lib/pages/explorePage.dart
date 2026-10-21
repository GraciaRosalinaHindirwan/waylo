import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:waylo/components/button.dart';
import 'package:waylo/components/infoChip.dart';
import 'package:waylo/service/location_service.dart';
import 'package:waylo/service/destination_filter_service.dart';
import 'package:geolocator/geolocator.dart';

import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/components/inspiringCard.dart';
import 'package:waylo/components/recommendCard.dart';
import 'package:waylo/components/customSearchBar.dart';
import 'package:waylo/layouts/homeLayout.dart';
import 'package:waylo/models/category.dart';
import 'package:waylo/models/destination.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/detailDestination.dart';
import 'package:waylo/repositories/category/category_repository.dart';
import 'package:waylo/repositories/category/category_repository_factory.dart';
import 'package:waylo/repositories/destination/destination_repository_factory.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';
import 'package:waylo/pages/profile.dart';
import 'package:waylo/service/user_preference_service.dart';
import 'package:waylo/service/recommendation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:waylo/service/session_storage.dart';

import 'package:waylo/pages/seeAllPage.dart';

class Explorepage extends StatefulWidget {
  const Explorepage({super.key});

  @override
  State<Explorepage> createState() => _ExplorepageState();
}

class _ExplorepageState extends State<Explorepage> {
  late final Future<List<Destination>> _destinationsFuture;
  
  final CategoryRepository _categoryRepository = CategoryRepositoryFactory.create();
  final DestinationFilterService _filterService = DestinationFilterService();
  Position? _userPosition;
  bool _loadingNearby = true;

  final UserPreferenceService _userPreferenceService =
    UserPreferenceService(
    Supabase.instance.client,
    SessionStorage(),
  );

  final RecommendationService _recommendationService =
      RecommendationService();

  late final Future<List<Destination>> _recommendedDestinationsFuture;

  final TextEditingController _minController = TextEditingController();
  final TextEditingController _maxController = TextEditingController();

  List<String> _districts = <String>[];

  static const List<(String, int?, int?)> budgetOptions = [
    ('Free', 0, 0),
    ('Under Rp20.000', null, 20000),
    ('Rp20.000 - 50.000', 20000, 50000),
    ('Above Rp50.000', 50000, null),
  ];

  List<Category> _categories = [];
  Set<int> _selectedCategoryIds = {};
  int? _minFee;
  int? _maxFee;
  String? _selectedDistrict;

  final LocationService _locationService = LocationService();
  String _currentCity = 'Mencari lokasi...';

  @override
  void initState() {
    super.initState();

    final repository = DestinationRepositoryFactory.create();

    // 1. Inisialisasi daftar destinasi terlebih dahulu
    _destinationsFuture = repository.getAllDestinations();

    // 2. Baru ambil rekomendasi berdasarkan preferensi
    _recommendedDestinationsFuture = _getRecommendedDestinations();

    // Inisialisasi lainnya tetap seperti kode kamu
    _destinationsFuture
        .then((destinations) {
          // Pertahankan kode debug yang sudah ada di sini
        })
        .catchError((e) {
          // Pertahankan penanganan error yang sudah ada di sini
        });

    _loadCurrentCity();
    _loadCategories();
    _loadUserPosition();
    _loadDistricts();
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final result = await _categoryRepository.getAllCategories();
    if (!mounted) return;
    setState(() => _categories = result);
  }

  Future<void> _loadDistricts() async {
  try {
    final destinations = await _destinationsFuture;
    final districts = _filterService.getDistricts(destinations);

    if (!mounted) return;

    setState(() {
      _districts = districts;
    });
  } catch (e) {
    debugPrint('Gagal memuat distrik: $e');
  }
}

Future<void> _openExploreNearbySeeAll() async {
  try {
    final allDestinations = await _destinationsFuture;
    final filteredDestinations = _applyFilter(allDestinations);

    // Jika lokasi belum tersedia, tampilkan halaman dengan list kosong.
    final position = _userPosition;

    final nearbyDestinations = position == null
        ? <Destination>[]
        : _filterService.getNearbyDestinations(
            destinations: filteredDestinations,
            userLatitude: position.latitude,
            userLongitude: position.longitude,
          );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExploreNearbySeeAllPage(
          destinations: nearbyDestinations,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Gagal membuka Destination Near You: $e');
  }
}


Future<void> _openInspiringSeeAll() async {
  try {
    final recommendedDestinations =
        await _recommendedDestinationsFuture;

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InspiringSeeAllPage(
          destinations: recommendedDestinations,
        ),
      ),
    );
  } catch (e) {
    debugPrint('Gagal membuka Inspiring Destination: $e');

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gagal memuat rekomendasi destinasi.'),
      ),
    );
  }
}

  bool get _filterActive =>
      _selectedCategoryIds.isNotEmpty ||
      _selectedDistrict != null ||
      _minFee != null ||
      _maxFee != null;

  List<Destination> _applyFilter(
    List<Destination> destinations,
  ) {
    return destinations.where((destination) {
      if (_selectedCategoryIds.isNotEmpty &&
          !destination.categories.any(
            (category) => _selectedCategoryIds.contains(category.id),
          )) {
        return false;
      }

      final fee = destination.fee ?? 0;

      if (_minFee != null && fee < _minFee!) return false;
      if (_maxFee != null && fee > _maxFee!) return false;

      // Filter berdasarkan district
      if (_selectedDistrict != null &&
          destination.location.districtName.trim() !=
              _selectedDistrict!.trim()) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildChip(
    String label,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Jangan tambahkan width: double.infinity di sini
        padding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.secondary : AppColors.card,
          borderRadius: BorderRadius.circular(8.53),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.button.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        Text(
          title,
          style: AppTextStyles.heading4.copyWith(color: Colors.black),
        ),
        child,
      ],
    );
  }

  Widget _buildPriceField(
    TextEditingController controller,
    String hint,
    VoidCallback onChanged,
  ) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (_) => onChanged(),
      style: AppTextStyles.body.copyWith(
        fontSize: 12,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.caption.copyWith(
          color: AppColors.textSecondary,
        ),
        prefixText: 'Rp ',
        prefixStyle: AppTextStyles.body.copyWith(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.card,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.53),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _openFilter() async {
    final tempCategories = {..._selectedCategoryIds};
    String? tempProvince = _selectedDistrict;
    _minController.text = _minFee?.toString() ?? '';
    _maxController.text = _maxFee?.toString() ?? '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            bool isBudgetSelected(int? min, int? max) =>
                int.tryParse(_minController.text) == min &&
                int.tryParse(_maxController.text) == max;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 24,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                    ),
                    Text(
                      'Filter',
                      style: AppTextStyles.heading3.copyWith(
                        color: Colors.black,
                      ),
                    ),
                    _buildSection(
                      'Category',
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final category in _categories)
                            if (category.name.toLowerCase() != 'other')
                              _buildChip(
                                category.name,
                                tempCategories.contains(category.id),
                                () => setSheetState(() {
                                  if (tempCategories.contains(category.id)) {
                                    tempCategories.remove(category.id);
                                  } else {
                                    tempCategories.add(category.id);
                                  }
                                }),
                              ),
                        ],
                      ),
                    ),
                    _buildSection(
                      'Budget',
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Row(
                            spacing: 8,
                            children: [
                              Expanded(
                                child: _buildPriceField(
                                  _minController,
                                  'Min price',
                                  () => setSheetState(() {}),
                                ),
                              ),
                              Expanded(
                                child: _buildPriceField(
                                  _maxController,
                                  'Max price',
                                  () => setSheetState(() {}),
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: budgetOptions
                                .map(
                                  (option) => _buildChip(
                                    option.$1,
                                    isBudgetSelected(option.$2, option.$3),
                                    () => setSheetState(() {
                                      _minController.text =
                                          option.$2?.toString() ?? '';
                                      _maxController.text =
                                          option.$3?.toString() ?? '';
                                    }),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    _buildSection(
                      'District',
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _districts.map((province) {
                          return _buildChip(
                            province,
                            tempProvince == province,
                            () => setSheetState(() {
                              tempProvince =
                                  tempProvince == province ? null : province;
                            }),
                          );
                        }).toList(),
                      ),
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'Reset',
                            borderRadius: 106.61,
                            backgroundColor: AppColors.border,
                            textColor: AppColors.textPrimary,
                            onPressed: () => setSheetState(() {
                              tempCategories.clear();
                              tempProvince = null;
                              _minController.clear();
                              _maxController.clear();
                            }),
                          ),
                        ),
                        Expanded(
                          child: CustomButton(
                            text: 'Apply',
                            borderRadius: 106.61,
                            onPressed: () {
                              setState(() {
                                _selectedCategoryIds = tempCategories;
                                _selectedDistrict = tempProvince;
                                _minFee = int.tryParse(_minController.text);
                                _maxFee = int.tryParse(_maxController.text);
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterButton() {
    return SizedBox(
      width: 54,
      height: 54,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ElevatedButton(
              onPressed: _openFilter,
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
          if (_filterActive)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
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

  Future<void> _loadUserPosition() async {
  try {
    final serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      debugPrint('GPS/location service tidak aktif');
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
    debugPrint('Gagal mengambil koordinat pengguna: $e');
  } finally {
    if (mounted) {
      setState(() {
        _loadingNearby = false;
      });
    }
  }
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

Future<List<Destination>> _getRecommendedDestinations() async {
  final destinations = await _destinationsFuture;
  final preferences =
      await _userPreferenceService.getUserPreferences();

  final recommended = _recommendationService.rankDestinations(
    destinations: destinations,
    preferredCategoryIds: preferences.categoryIds,
    preferredDistrictIds: preferences.districtIds,
    favoriteDestinationIds: preferences.favoriteDestinationIds,
    userLatitude: _userPosition?.latitude,
    userLongitude: _userPosition?.longitude,
  );

  debugPrint('PREFERRED CATEGORY: ${preferences.categoryIds}');
  debugPrint('PREFERRED DISTRICT: ${preferences.districtIds}');
  debugPrint(
    'FAVORITE DESTINATION IDS: '
    '${preferences.favoriteDestinationIds}',
  );
  debugPrint('TOTAL DESTINATIONS: ${destinations.length}');
  debugPrint('TOTAL RECOMMENDATIONS: ${recommended.length}');

  return recommended;
}

//UI
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
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            case 1:
              // Sudah berada di Explore
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
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
          _buildFilterButton(),
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
                onPressed: _openExploreNearbySeeAll,
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

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('Belum ada destinasi'),
                  );
                }

                if (_loadingNearby) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (_userPosition == null) {
                  return const Center(
                    child: Text('Lokasi pengguna tidak tersedia'),
                  );
                }

                final destinations = _applyFilter(snapshot.data ?? []);

                final nearbyDestinations =
                    _filterService.getNearbyDestinations(
                  destinations: destinations,
                  userLatitude: _userPosition!.latitude,
                  userLongitude: _userPosition!.longitude,
                );

                if (nearbyDestinations.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Tidak ada destinasi dalam radius 10 km',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: nearbyDestinations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final destination = nearbyDestinations[index];
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
                  },
                );
              }),
            ),
          ),

          SizedBox(height: 24), 

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
                onPressed: _openInspiringSeeAll,
                child: Text(
                  'See All',
                  style: AppTextStyles.body.copyWith(color: AppColors.accent),
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          SizedBox(
            height: 160,
            child: FutureBuilder<List<Destination>>(
              future: _recommendedDestinationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  debugPrint(
                    'Error Inspiring Destination: ${snapshot.error}',
                  );
                  debugPrint(
                    'Stack trace: ${snapshot.stackTrace}',
                  );

                  return Center(
                    child: Text(
                      'Gagal memuat: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                final destinations = snapshot.data ?? [];

                if (destinations.isEmpty) {
                  return Center(
                    child: Text(
                      _filterActive
                          ? 'Tidak ada destinasi yang cocok'
                          : 'Belum ada destinasi',
                    ),
                  );
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