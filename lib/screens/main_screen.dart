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
    final isWideLayout = MediaQuery.of(context).size.width >= 900;
    final destinations = const [
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
    ];

    final pageContent = AnimatedSwitcher(
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: pages[currentIndex],
          ),
        ),
      ),
    );

    if (isWideLayout) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              backgroundColor: AppTheme.darkGreen,
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              indicatorColor: AppTheme.mossGreen,
              labelType: NavigationRailLabelType.selected,
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined, color: AppTheme.beige),
                  selectedIcon: Icon(Icons.home, color: AppTheme.darkGreen),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.assignment_outlined, color: AppTheme.beige),
                  selectedIcon: Icon(Icons.assignment, color: AppTheme.darkGreen),
                  label: Text('Reports'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.person_outline, color: AppTheme.beige),
                  selectedIcon: Icon(Icons.person, color: AppTheme.darkGreen),
                  label: Text('Profile'),
                ),
              ],
            ),
            Expanded(child: pageContent),
          ],
        ),
      );
    }

    return Scaffold(
      body: pageContent,
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.darkGreen,
        indicatorColor: AppTheme.mossGreen,
        selectedIndex: currentIndex,
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
        destinations: destinations,
      ),
    );
  }
}