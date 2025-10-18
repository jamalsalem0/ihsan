import 'dart:ui';
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ihsan/features/adhkar/presentation/adhkar_hub_screen.dart';
import 'package:ihsan/features/quran/presentation/quran_screen.dart';
import 'package:ihsan/features/settings/presentation/settings_screen.dart';
import '../home/home_screen.dart';

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  final _pageController = PageController(initialPage: 0);
  final _notchController = NotchBottomBarController(index: 0);

  final List<Widget> _bottomBarPages = [
    const HomeScreen(),
    const QuranScreen(),
    const AdhkarHubScreen(),
    const SettingsScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _bottomBarPages,
      ),
      extendBody: true,
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: AnimatedNotchBottomBar(
            notchBottomBarController: _notchController,
            color: Colors.white.withOpacity(0.08),
            showLabel: true,
            notchColor: const Color(0xff8a79b8),
            removeMargins: false,
            bottomBarWidth: 500,
            durationInMilliSeconds: 300,
            itemLabelStyle: GoogleFonts.amiri(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            bottomBarItems: const [
              BottomBarItem(
                inActiveItem: Icon(Icons.home_outlined, color: Colors.white70),
                activeItem: Icon(Icons.home_filled, color: Colors.white),
                itemLabel: 'الرئيسية',
              ),
              BottomBarItem(
                inActiveItem: Icon(Icons.book_outlined, color: Colors.white70),
                activeItem: Icon(Icons.menu_book, color: Colors.white),
                itemLabel: 'القرآن',
              ),
              BottomBarItem(
                inActiveItem: Icon(
                  Icons.watch_later_outlined,
                  color: Colors.white70,
                ),
                activeItem: Icon(Icons.watch_later, color: Colors.white),
                itemLabel: 'المسبحة',
              ),
              BottomBarItem(
                inActiveItem: Icon(
                  Icons.settings_outlined,
                  color: Colors.white70,
                ),
                activeItem: Icon(Icons.settings, color: Colors.white),
                itemLabel: 'الإعدادات',
              ),
            ],
            onTap: (index) {
              _pageController.jumpToPage(index);
            },
            kIconSize: 24.0,
            kBottomRadius: 28.0,
          ),
        ),
      ),
    );
  }
}
