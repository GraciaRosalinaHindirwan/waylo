import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

import 'package:waylo/components/selectionButton.dart';
import 'package:waylo/components/button.dart';
import 'package:waylo/models/category.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/category/category_repository.dart';
import 'package:waylo/repositories/category/category_repository_factory.dart';
import 'package:waylo/repositories/user/user_repository.dart';
import 'package:waylo/repositories/district/district_repository.dart';
import 'package:waylo/repositories/district/district_repository_factory.dart';

class UserPreferencePage extends StatefulWidget {
  final User user;
  final UserRepository userRepository;

  const UserPreferencePage({
    super.key,
    required this.user,
    required this.userRepository,
  });

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  late final UserRepository _userRepository;

  final CategoryRepository _categoryRepository = CategoryRepositoryFactory.create();

  final DistrictRepository _districtRepository = DistrictRepositoryFactory.create();

  List<District> districtOptions = [];
  List<District> selectedDistricts = [];

  List<Category> categoryOptions = [];
  List<String> selectedCategories = [];

  bool isSaving = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository;
    loadOptions();
  }

  Future<void> loadOptions() async {
    try {
      final categories =
          await _categoryRepository.getAllCategories();

      final districts =
          await _districtRepository.getAllDistricts();

      if (!mounted) return;

      setState(() {
        categoryOptions = categories;
        districtOptions = districts;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat preferensi: $e'),
        ),
      );
    }
  }

  bool get canSave =>
      selectedDistricts.isNotEmpty && selectedCategories.isNotEmpty;

  Future<void> save() async {
  if (isSaving) return;

  setState(() => isSaving = true);

  try {
    await context.read<AuthService>().savePreferences(
      districtIds: selectedDistricts.map((d) => d.id).toList(),
      categoryIds: categoryOptions
          .where((c) => selectedCategories.contains(c.name))
          .map((c) => c.id)
          .toList(),
    );

    if (!mounted) return;
    context.go('/home');
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan preferensi: $e')),
      );
    }
  } finally {
    if (mounted) {
      setState(() => isSaving = false);
    }
  }
}

  Widget buildSection(String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Text(
            title,
            style: AppTextStyles.heading4.copyWith(color: Colors.black),
          ),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/img/backgroundDown.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Text(
                    'Tell us what you’re looking for',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildSection(
                                'District',
                                SelectionButton(
                                  options: districtOptions.map((d) => d.name).toList(),
                                  multiSelect: true,
                                  onMultiChanged: (values) {
                                    setState(() {
                                      selectedDistricts = districtOptions
                                          .where((d) => values.contains(d.name))
                                          .toList();
                                    });
                                  },
                                ),
                              ),
                              if (categoryOptions.isNotEmpty) 
                                buildSection(
                                  'Category',
                                  SelectionButton(
                                    options: categoryOptions
                                        .map((c) => c.name)
                                        .toList(),
                                    multiSelect: true,
                                    onMultiChanged: (values) {
                                      setState(() {
                                        selectedCategories = values;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: CustomButton(
                    text: isSaving ? 'Saving...' : 'Save',
                    borderRadius: 106.61,
                    onPressed: isSaving
                        ? () {}
                        : () {
                            if (!canSave) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Pilih minimal 1 district dan 1 category terlebih dahulu',
                                  ),
                                ),
                              );
                              return;
                            }

                            save();
                          },
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