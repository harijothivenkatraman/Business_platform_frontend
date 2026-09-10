import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/owner/owner_dashboard.dart';
import 'screens/owner/manage_plans_screen.dart';
import 'screens/trainer/trainer_dashboard.dart';
import 'screens/member/member_dashboard.dart';

void main() {
  runApp(
    ChangeNotifierProvider(create: (_) => AuthProvider()..init(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Business Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true, brightness: Brightness.light),
      routes: {'/home': (_) => const HomeShell()},
      home: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => auth.isLoggedIn ? const HomeShell() : const LoginScreen(),
      ),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final role = auth.role;

    final pages = _getPages(role);
    final navItems = _getNavItems(role);

    return Scaffold(
      appBar: AppBar(
        title: Text('${role[0].toUpperCase()}${role.substring(1)} Portal'),
        actions: [
          Chip(label: Text(auth.userName), avatar: const Icon(Icons.person, size: 18)),
          const SizedBox(width: 8),
          if (role == 'owner') IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Business ID',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Business ID: ${auth.businessId}')),
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () async {
            await auth.logout();
            if (context.mounted) Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
          }),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: pages),
      bottomNavigationBar: navItems.length > 1
          ? NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              destinations: navItems,
            )
          : null,
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
        return [const Center(child: Text('Unknown role'))];
    }
  }

  List<NavigationDestination> _getNavItems(String role) {
    switch (role) {
      case 'owner':
        return const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.card_membership), label: 'Plans'),
        ];
      case 'trainer':
        return const [NavigationDestination(icon: Icon(Icons.dashboard), label: 'Sessions')];
      case 'member':
        return const [NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard')];
      default:
        return const [NavigationDestination(icon: Icon(Icons.home), label: 'Home')];
    }
  }
}
