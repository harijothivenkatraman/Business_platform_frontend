import 'package:flutter/material.dart';
import '../models/kyc_status.dart';
import '../theme/app_colors.dart';

class B2BStatusBadge extends StatelessWidget {
  final String status;
  final String? label;

  const B2BStatusBadge({
    super.key,
    required this.status,
    this.label,
  });

  factory B2BStatusBadge.fromKyc(KycStatus kyc) {
    return B2BStatusBadge(status: kyc.name, label: kyc.label);
  }

  @override
  Widget build(BuildContext context) {
    final s = status.toLowerCase();
    Color bg;
    Color fg;
    String text = label ?? status.toUpperCase();

    if (s == 'verified' || s == 'active' || s == 'confirmed' || s == 'paid') {
      bg = AppColors.successBg;
      fg = AppColors.success;
      text = label ?? (s == 'verified' ? 'Verified' : s == 'active' ? 'Active' : 'Confirmed');
    } else if (s == 'pending' || s == 'in_review') {
      bg = AppColors.warningBg;
      fg = AppColors.warning;
      text = label ?? (s == 'in_review' ? 'In Review' : 'Pending');
    } else if (s == 'rejected' || s == 'cancelled' || s == 'expired') {
      bg = AppColors.dangerBg;
      fg = AppColors.danger;
      text = label ?? (s == 'rejected' ? 'Rejected' : 'Cancelled');
    } else {
      bg = AppColors.borderLight;
      fg = AppColors.textMuted;
      text = label ?? status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fg.withOpacity(0.2), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
