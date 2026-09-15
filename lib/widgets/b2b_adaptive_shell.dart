import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../theme/app_colors.dart';
import 'b2b_avatar_chip.dart';

class B2BNavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const B2BNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}

class B2BAdaptiveShell extends StatefulWidget {
  final List<Widget> pages;
  final List<B2BNavItem> navItems;
  final String portalTitle;

  const B2BAdaptiveShell({
    super.key,
    required this.pages,
    required this.navItems,
    required this.portalTitle,
  });

  @override
  State<B2BAdaptiveShell> createState() => _B2BAdaptiveShellState();
}

class _B2BAdaptiveShellState extends State<B2BAdaptiveShell> {
  int _selectedIndex = 0;

  void _copyBusinessId(BuildContext context, String businessId) {
    Clipboard.setData(ClipboardData(text: businessId));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied Business ID: $businessId')),
    );
  }

  void _logout(BuildContext context, AuthProvider auth) async {
    await auth.logout();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDesktop = MediaQuery.of(context).size.width > 900;

    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            // Enterprise Sidebar
            Container(
              width: 250,
              color: AppColors.sidebarBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Brand Header
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.business_center, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'LogFuze',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              Text(
                                widget.portalTitle,
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.white12, height: 1),
                  const SizedBox(height: 16),

                  // Navigation Items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: widget.navItems.length,
                      itemBuilder: (ctx, idx) {
                        final item = widget.navItems[idx];
                        final isSelected = _selectedIndex == idx;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.sidebarActive : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? const Border(left: BorderSide(color: AppColors.accent, width: 3))
                                : null,
                          ),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected ? AppColors.accent : AppColors.textMuted,
                              size: 20,
                            ),
                            title: Text(
                              item.label,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textMuted,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            onTap: () => setState(() => _selectedIndex = idx),
                          ),
                        );
                      },
                    ),
                  ),

                  // Business ID Copy Action (for Owners)
                  if (auth.role == 'owner' && auth.businessId.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => _copyBusinessId(context, auth.businessId),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.share, size: 16, color: AppColors.accent),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Business ID',
                                        style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
                                    Text(auth.businessId,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                        overflow: TextOverflow.ellipsis),
                                  ],
                                ),
                              ),
                              const Icon(Icons.copy, size: 14, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                      ),
                    ),

                  const Divider(color: Colors.white12, height: 1),

                  // User Info & Signout
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accent,
                          child: Text(
                            auth.userName.isNotEmpty ? auth.userName[0].toUpperCase() : 'U',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(auth.userName,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis),
                              Text(auth.role.toUpperCase(),
                                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                          tooltip: 'Sign Out',
                          onPressed: () => _logout(context, auth),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Content Area
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: widget.pages,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile / Tablet Shell
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.portalTitle),
        actions: [
          B2BAvatarChip(
            name: auth.userName,
            role: auth.role,
            onCopyBusinessId: auth.role == 'owner' ? () => _copyBusinessId(context, auth.businessId) : null,
            onLogout: () => _logout(context, auth),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: widget.pages,
      ),
      bottomNavigationBar: widget.navItems.length > 1
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: widget.navItems
                  .map((item) => NavigationDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon, color: AppColors.primary),
                        label: item.label,
                      ))
                  .toList(),
            )
          : null,
    );
  }
}
