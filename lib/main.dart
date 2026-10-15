import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/login_page.dart';
import 'package:waylo/service/session_storage.dart';
import 'package:waylo/factories/user_repository_factory.dart';
import 'package:waylo/pages/userPreference.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //jangan dihapus 
   // Inisialisasi database zona waktu sebelum aplikasi berjalan.
  tzdata.initializeTimeZones();

  
try {

  final repository = await UserRepositoryFactory.create();

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
      debugPrint('Path: ${state.matchedLocation}');
      debugPrint('User: ${user?.username}');
      debugPrint(
        'hasCompletedPreference: ${user?.hasCompletedPreference}',
      );
      final isLoginPage = state.matchedLocation == '/login';
      final isPreferencePage = state.matchedLocation == '/preference';

      if(user == null) {
        return isLoginPage ? null : '/login'; 
      }

      if (!user.hasCompletedPreference) {
        return isPreferencePage ? null : '/preferance';
      }

      if (isLoginPage || isPreferencePage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => HomePage(),
      ),
      GoRoute(
        path: '/preferance',
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