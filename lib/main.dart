import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:waylo/service/auth_service.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:waylo/pages/home.dart';
import 'package:waylo/pages/login_page.dart';
import 'package:waylo/service/session_storage.dart';
import 'package:waylo/factories/user_repository_factory.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //jangan dihapus 
   // Inisialisasi database zona waktu sebelum aplikasi berjalan.
  tzdata.initializeTimeZones();

  try {
    final repository = UserRepositoryFactory.create(); 
    // await repository.initializeDummyUsers();
    final authService = AuthService(repository, SessionStorage()); 

    final router = GoRouter(
      initialLocation: '/login',
      refreshListenable: authService,
      redirect: (context, state) {
        final isLoggedIn = authService.isLoggedIn;
        final isLoginPage = state.matchedLocation == '/login';

        // Belum login dan membuka halaman internal.
        if (!isLoggedIn && !isLoginPage) {
          return '/login';
        }

        // Sudah login dan membuka halaman login.
        if (isLoggedIn && isLoginPage) {
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