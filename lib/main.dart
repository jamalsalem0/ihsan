import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ihsan/features/settings/presentation/notification_service.dart';

import 'features/splash/splash_screen.dart';
import 'features/shell/bottom_nav_shell.dart';
import 'features/quran/presentation/quran_screen.dart';
import 'features/quran/presentation/surah_reader_screen.dart';
import 'features/adhkar/presentation/adhkar_hub_screen.dart';
import 'features/adhkar/presentation/adhkar_reader_screen.dart';

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/home', builder: (context, state) => const BottomNavShell()),
    GoRoute(path: '/quran', builder: (context, state) => const QuranScreen()),
    GoRoute(
      path: '/surah/:surahNumber',
      builder: (context, state) {
        final int surahNumber = int.parse(state.pathParameters['surahNumber']!);
        return SurahReaderScreen(surahNumber: surahNumber);
      },
    ),
    GoRoute(
      path: '/adhkar',
      builder: (context, state) => const AdhkarHubScreen(),
      routes: [
        GoRoute(
          path: ':categoryId',
          builder: (context, state) {
            final categoryId = int.parse(state.pathParameters['categoryId']!);
            return AdhkarReaderScreen(categoryId: categoryId);
          },
        ),
      ],
    ),
  ],
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();

  await notificationService.init();

  await notificationService.requestPermissions();

  runApp(const ProviderScope(child: IhsanApp()));
}

class IhsanApp extends StatelessWidget {
  const IhsanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      title: 'Ihsan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDFCEC),
        textTheme: GoogleFonts.amiriTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xffD4AF37),
          brightness: Brightness.light,
          background: const Color(0xFFFDFCEC),
        ),
      ),
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
  }
}
