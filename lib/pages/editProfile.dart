import 'package:flutter/material.dart';
import 'package:waylo/repositories/user/user_repository_factory.dart';

import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:waylo/components/inputfield.dart';
import 'package:waylo/components/button.dart';
import 'package:waylo/components/buttomNav.dart';
import 'package:waylo/models/user.dart';
import 'package:waylo/pages/explorePage.dart';
import 'package:waylo/pages/home.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:waylo/service/password_hasher.dart';
import 'package:waylo/theme/appColors.dart';
import 'package:waylo/theme/app_text_styles.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _fullnameController;
  late final TextEditingController _usernameController;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool editFullname = false;
  bool editUsername = false;
  bool isSaving = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthService>().currentUser;
    _fullnameController = TextEditingController(text: user?.fullname ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.textPrimary,
              ),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.textPrimary,
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _getImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    await context.read<AuthService>().setProfileImage(bytes);
  }

  
  Future<void> save() async {
    final authService = context.read<AuthService>();
    final repository = await UserRepositoryFactory.create();
    final user = authService.currentUser;

    if (user == null) {
      showMessage('Belum login');
      return;
    }

    final fullname = _fullnameController.text.trim();
    final username = _usernameController.text.trim();
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (fullname.isEmpty || username.isEmpty) {
      showMessage('Fullname dan username tidak boleh kosong');
      return;
    }

    if (newPassword.isNotEmpty) {
      if (newPassword.length < 8) {
        showMessage('Password minimal 8 karakter');
        return;
      }

      if (newPassword != confirmPassword) {
        showMessage('Konfirmasi password tidak cocok');
        return;
      }
    }

    setState(() => isSaving = true);

    try {
      // Periksa apakah username sudah digunakan.
      if (username != user.username) {
        final existing = await repository.getUserByUsername(username);

        if (existing != null) {
          if (!mounted) return;

          setState(() => isSaving = false);
          showMessage('Username sudah digunakan');
          return;
        }
      }

      // Pertahankan password lama jika tidak diganti.
      final passwordToSave = newPassword.isEmpty
          ? user.password
          : await PasswordHasher.hashPassword(newPassword);

      final updatedUser = await repository.updateUser(
        User(
          id: user.id,
          fullname: fullname,
          username: username,
          password: passwordToSave,
          districts: user.districts,
          categories: user.categories,
          hasCompletedPreference: user.hasCompletedPreference,
          createdAt: user.createdAt,
          updatedAt: DateTime.now(),
          profileImageBase64: user.profileImageBase64,
        ),
      );

      // Perbarui user aktif setelah database berhasil di-update.
      debugPrint(
        'BEFORE: ${authService.currentUser?.hasCompletedPreference}',
      );
      debugPrint(
        'UPDATED USER: ${updatedUser.hasCompletedPreference}',
      );

      authService.setCurrentUser(updatedUser);

      debugPrint(
        'AFTER: ${authService.currentUser?.hasCompletedPreference}',
      );


      if (!mounted) return;

      setState(() => isSaving = false);
      Navigator.pop(context);

    } catch (e, stackTrace) {
      debugPrint('Gagal memperbarui profile: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() => isSaving = false);
      showMessage('Gagal memperbarui profile: $e');
    }
  }

  Widget buildHeader() {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Text(
              'EDIT PROFILE',
              textAlign: TextAlign.center,
              style: AppTextStyles.heading3.copyWith(color: Colors.black),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: AppColors.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return SizedBox(
      width: double.infinity,
      child: Text(
        title,
        style: AppTextStyles.heading4.copyWith(color: Colors.black),
      ),
    );
  }

  Widget buildRoundButton({
    required IconData icon,
    required VoidCallback? onTap,
    double size = 50,
    Color color = AppColors.card,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(icon, size: 20, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool editing,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: IgnorePointer(
                ignoring: !editing,
                child: Inputfield(label: '', controller: controller),
              ),
            ),
            buildRoundButton(
              icon: editing ? Icons.check : Icons.edit_outlined,
              onTap: onToggle,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggleObscure,
  }) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          enableSuggestions: false,
          autocorrect: false,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAvatar() {
    final profileImageBytes = context.watch<AuthService>().profileImageBytes;

    return Center(
      child: SizedBox(
        width: 150,
        height: 150,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 150,
              height: 150,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(
                    width: 5,
                    color: AppColors.border,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 92,
                  height: 92,
                  child: ClipOval(
                    child: profileImageBytes != null
                        ? Image.memory(
                            profileImageBytes,
                            fit: BoxFit.cover,
                            width: 92,
                            height: 92,
                          )
                        : const Icon(
                            Icons.person_outline,
                            size: 92,
                            color: AppColors.secondary,
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: pickProfileImage,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ),
          ],
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
            child: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
                child: Column(
                  spacing: 16,
                  children: [
                    buildHeader(),
                    buildAvatar(),
                    const SizedBox(height: 8),
                    buildSectionTitle('Profile'),
                    buildEditableField(
                      label: 'Fullname',
                      controller: _fullnameController,
                      editing: editFullname,
                      onToggle: () =>
                          setState(() => editFullname = !editFullname),
                    ),
                    buildEditableField(
                      label: 'Username',
                      controller: _usernameController,
                      editing: editUsername,
                      onToggle: () =>
                          setState(() => editUsername = !editUsername),
                    ),
                    const SizedBox(height: 8),
                    buildSectionTitle('Edit Password'),
                    buildPasswordField(
                      label: 'New Password',
                      controller: _newPasswordController,
                      obscure: _obscureNew,
                      onToggleObscure: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                    buildPasswordField(
                      label: 'Confirm New Password',
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirm,
                      onToggleObscure: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    const SizedBox(height: 8),
                    CustomButton(
                      text: isSaving ? 'Saving...' : 'Save',
                      borderRadius: 106.61,
                      onPressed: isSaving ? () {} : save,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
          CustomBottomNavBar(
            currentIndex: 2,
            onTap: (index) {
              if (index == 0) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false,
                );
              } else if (index == 1) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => Explorepage()),
                  (route) => false,
                );
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}