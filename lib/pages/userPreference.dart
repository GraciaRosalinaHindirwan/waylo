import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:waylo/service/auth_service.dart';

import 'package:waylo/layouts/subPageLayout.dart';
import 'package:waylo/components/selectionButton.dart';
import 'package:waylo/components/button.dart';
import 'package:waylo/models/category.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/repositories/category/category_repository.dart';
import 'package:waylo/repositories/category/category_repository_factory.dart';
import 'package:waylo/repositories/user/user_repository.dart';
import 'package:waylo/theme/app_text_styles.dart';

class UserPreferencePage extends StatefulWidget {
  final User user;
  final UserRepository userRepository;

  const UserPreferencePage({super.key, required this.user, required this.userRepository});

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  late final UserRepository _userRepository; 
  final CategoryRepository _categoryRepository =
      CategoryRepositoryFactory.create();

  static const List<String> destinationOptions = [
    'Japan',
    'Indonesia',
    'South Korea',
    'Thailand',
    'China',
  ];

  List<Category> categoryOptions = [];
  String? selectedDestination;
  String? selectedCategory;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _userRepository = widget.userRepository;
    loadCategories();
  }

  Future<void> loadCategories() async {
    final result = await _categoryRepository.getAllCategories();
    if (!mounted) return;
    setState(() => categoryOptions = result);
  }

  Future<void> save() async {
    if (isSaving) return;

    setState(() => isSaving = true);

    try {
      final user = widget.user;

      final destinations = selectedDestination == null
          ? user.destinations
          : [selectedDestination!];

      final categories = selectedCategory == null
          ? user.categories
          : categoryOptions
              .where((c) => c.name == selectedCategory)
              .toList();
      
      debugPrint('1. Tombol Save ditekan');

      final updatedUser = await _userRepository.updateUser(
        User(
          id: user.id,
          fullname: user.fullname,
          username: user.username,
          password: user.password,
          destinations: destinations,
          categories: categories,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
          hasCompletedPreference: true,
        ),
      );

      debugPrint('2. Preferensi berhasil disimpan');

      if (!mounted) return;

      context.read<AuthService>().setCurrentUser(updatedUser);
      debugPrint('3. Current user diperbarui');
      context.go('/home');
      debugPrint('4. Navigasi ke Home dijalankan');
    } catch (e) {
      debugPrint('Gagal menyimpan preferensi: $e');

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
    return SubPageLayout(
      title: 'Tell us what you’re looking for',
      content: Stack(
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
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildSection(
                        'Destination',
                        SelectionButton(
                          options: destinationOptions,
                          onChanged: (value) => selectedDestination = value,
                        ),
                      ),
                      if (categoryOptions.isNotEmpty)
                        buildSection(
                          'Category',
                          SelectionButton(
                            options:
                                categoryOptions.map((c) => c.name).toList(),
                            onChanged: (value) => selectedCategory = value,
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
                  onPressed: isSaving ? () {} : save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}