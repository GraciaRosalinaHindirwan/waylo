import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:waylo/pages/regist.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/login_page.dart';
import 'package:waylo/service/session_storage.dart';
import 'package:waylo/repositories/user/user_repository_factory.dart';
import 'package:waylo/pages/userPreference.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //jangan dihapus 
   // Inisialisasi database zona waktu sebelum aplikasi berjalan.
  tzdata.initializeTimeZones();

  
try {
  await Supabase.initialize(
    url: 'https://hardbbxlyzwdunrfaaib.supabase.co',
    publishableKey: 'sb_publishable_LWGQD8hLHrvS2q2cbm2vMA_jxmXsVZE',
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

      debugPrint('=== ROUTER REDIRECT ===');
      debugPrint('Current location: ${state.matchedLocation}');
      debugPrint('User: $user');
      debugPrint('hasCompletedPreference: ${user?.hasCompletedPreference}');

      final isLoginPage = state.matchedLocation == '/login';
      final isRegisterPage = state.matchedLocation == '/register'; //apakah skrg halaman login
      final isPreferencePage = state.matchedLocation == '/preference';

      if(user == null) {
        return (isLoginPage || isRegisterPage) ? null : '/login';
        //user yang blm login bisa akses register dan login 
      }

      if (!user.hasCompletedPreference) {
        return isPreferencePage ? null : '/preference';
      }

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
        }
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