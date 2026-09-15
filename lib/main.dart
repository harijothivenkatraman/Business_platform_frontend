import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/business_dashboard_provider.dart';
import 'screens/login_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/owner/manage_plans_screen.dart';
import 'screens/trainer/trainer_dashboard.dart';
import 'screens/member/member_dashboard.dart';
import 'theme/app_theme.dart';
import 'widgets/b2b_adaptive_shell.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => BusinessDashboardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routes: {'/home': (_) => const HomeShell()},
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) =>
            auth.isLoggedIn ? const HomeShell() : const LoginScreen(),
      ),
    );
  }
}

class HomeShell extends StatelessWidget {
  const HomeShell({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;

    final pages = _getPages(role);
    final navItems = _getNavItems(role);
    final portalTitle = role.isNotEmpty
        ? '${role[0].toUpperCase()}${role.substring(1)} Portal'
        : 'Enterprise Portal';

    return B2BAdaptiveShell(
      portalTitle: portalTitle,
      pages: pages,
      navItems: navItems,
    );
  }

  List<Widget> _getPages(String role) {
    switch (role) {
      case 'owner':
        return [const OwnerDashboard(), const ManagePlansScreen()];
      case 'trainer':
        return [const TrainerDashboard()];
      case 'member':
        return [const MemberDashboard()];
      default:
        return [const Center(child: Text('Unknown role account'))];
    }
  }

  List<B2BNavItem> _getNavItems(String role) {
    switch (role) {
      case 'owner':
        return const [
          B2BNavItem(
            icon: Icons.dashboard_outlined,
            selectedIcon: Icons.dashboard_rounded,
            label: 'Overview',
          ),
          B2BNavItem(
            icon: Icons.card_membership_outlined,
            selectedIcon: Icons.card_membership_rounded,
            label: 'Membership Plans',
          ),
        ];
      case 'trainer':
        return const [
          B2BNavItem(
            icon: Icons.calendar_month_outlined,
            selectedIcon: Icons.calendar_month_rounded,
            label: 'Schedule & Slots',
          ),
        ];
      case 'member':
        return const [
          B2BNavItem(
            icon: Icons.person_outline,
            selectedIcon: Icons.person_rounded,
            label: 'My Membership',
          ),
        ];
      default:
        return const [
          B2BNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
          ),
        ];
    }
  }
}
