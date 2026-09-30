import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'reports_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;

  final pages = const [
    HomeScreen(),
    ReportsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 450),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(.08, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(currentIndex),
          child: pages[currentIndex],
        ),
      ),

      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.darkGreen,

        // Green highlight behind selected item
        indicatorColor: AppTheme.mossGreen,

        selectedIndex: currentIndex,

        // ⭐ THIS MAKES THE LABELS VISIBLE
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
          (states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              );
            }

            return const TextStyle(
              color: AppTheme.beige,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          },
        ),

        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: AppTheme.beige,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: AppTheme.darkGreen,
            ),
            label: "Home",
          ),

          NavigationDestination(
            icon: Icon(
              Icons.assignment_outlined,
              color: AppTheme.beige,
            ),
            selectedIcon: Icon(
              Icons.assignment,
              color: AppTheme.darkGreen,
            ),
            label: "Reports",
          ),

          NavigationDestination(
            icon: Icon(
              Icons.person_outline,
              color: AppTheme.beige,
            ),
            selectedIcon: Icon(
              Icons.person,
              color: AppTheme.darkGreen,
            ),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}