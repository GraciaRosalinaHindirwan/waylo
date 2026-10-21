import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:waylo/local/hive_cache_test.dart';
import 'package:waylo/pages/regist.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/login_page.dart';
import 'package:waylo/service/session_storage.dart';
import 'package:waylo/repositories/user/user_repository_factory.dart';
import 'package:waylo/pages/userPreference.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database zona waktu sebelum aplikasi berjalan.
  tzdata.initializeTimeZones();

  // Inisialisasi database lokal Hive.
  await Hive.initFlutter();
  debugPrint('Hive berhasil diinisialisasi');

  await testHiveCache();

  try {
    await Supabase.initialize(
      url: 'https://hardbbxlyzwdunrfaaib.supabase.co',
      publishableKey:
          'sb_publishable_LWGQD8hLHrvS2q2cbm2vMA_jxmXsVZE',
    );

    final supabase = Supabase.instance.client;

    final repository = await UserRepositoryFactory.create();
    debugPrint('Repository aktif: ${repository.runtimeType}');

    final authService = AuthService(
      repository,
      SessionStorage(),
    );

    await authService.restoreSession();

    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: authService,
      redirect: (context, state) {
        final user = authService.currentUser;
        final location = state.matchedLocation;

        final isLoginPage = location == '/login';
        final isRegisterPage = location == '/register';
        final isPreferencePage = location == '/preference';

        debugPrint('=== ROUTER REDIRECT ===');
        debugPrint('Current location: $location');
        debugPrint('User ID: ${user?.id}');
        debugPrint(
          'hasCompletedPreference: ${user?.hasCompletedPreference}',
        );

        // Belum login: hanya boleh membuka login dan register.
        if (user == null) {
          return (isLoginPage || isRegisterPage) ? null : '/login';
        }

        // Sudah login, tetapi belum mengisi preferensi.
        if (user.hasCompletedPreference == false) {
          return isPreferencePage ? null : '/preference';
        }

        // Sudah login dan preferensi selesai.
        if (isLoginPage || isPreferencePage) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) {
            debugPrint('LOGIN PAGE BUILDER DIPANGGIL');
            return const LoginPage();
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomePage(),
        ),
        GoRoute(
          path: '/preference',
          builder: (context, state) {
            final user = authService.currentUser!;
            return UserPreferencePage(
              user: user,
              userRepository: repository,
            );
          },
        ),
      ],
    );

    runApp(
      ChangeNotifierProvider<AuthService>.value(
        value: authService,
        child: MyApp(router: router),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('Gagal menjalankan aplikasi: $e');
    debugPrintStack(stackTrace: stackTrace);
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  final GoRouter router;

  const MyApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}