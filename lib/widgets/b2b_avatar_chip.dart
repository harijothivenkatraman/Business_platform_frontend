import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class B2BAvatarChip extends StatelessWidget {
  final String name;
  final String role;
  final VoidCallback? onLogout;
  final VoidCallback? onCopyBusinessId;

  const B2BAvatarChip({
    super.key,
    required this.name,
    required this.role,
    this.onLogout,
    this.onCopyBusinessId,
  });

  String _getInitials(String str) {
    if (str.trim().isEmpty) return 'U';
    final parts = str.trim().split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return str.substring(0, str.length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'User menu',
      offset: const Offset(0, 48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      itemBuilder: (ctx) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text(role.toUpperCase(), style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
        const PopupMenuDivider(),
        if (onCopyBusinessId != null)
          const PopupMenuItem(
            value: 'copy_id',
            child: Row(
              children: [
                Icon(Icons.copy, size: 18, color: AppColors.textSecondary),
                SizedBox(width: 8),
                Text('Copy Business ID'),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 18, color: AppColors.danger),
              SizedBox(width: 8),
              Text('Sign Out', style: TextStyle(color: AppColors.danger)),
            ],
          ),
        ),
      ],
      onSelected: (val) {
        if (val == 'logout') onLogout?.call();
        if (val == 'copy_id') onCopyBusinessId?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.primary,
              child: Text(
                _getInitials(name),
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
