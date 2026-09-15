import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum KycStatus {
  notSubmitted,
  pending,
  inReview,
  verified,
  rejected;

  static KycStatus fromString(String? s) {
    switch (s?.toLowerCase()) {
      case 'verified':
        return KycStatus.verified;
      case 'in_review':
        return KycStatus.inReview;
      case 'pending':
        return KycStatus.pending;
      case 'rejected':
        return KycStatus.rejected;
      default:
        return KycStatus.notSubmitted;
    }
  }

  String get label {
    switch (this) {
      case KycStatus.verified:
        return 'Verified';
      case KycStatus.inReview:
        return 'In Review';
      case KycStatus.pending:
        return 'Pending';
      case KycStatus.rejected:
        return 'Rejected';
      case KycStatus.notSubmitted:
        return 'Not Submitted';
    }
  }

  Color get color {
    switch (this) {
      case KycStatus.verified:
        return AppColors.success;
      case KycStatus.inReview:
      case KycStatus.pending:
        return AppColors.warning;
      case KycStatus.rejected:
        return AppColors.danger;
      case KycStatus.notSubmitted:
        return AppColors.textMuted;
    }
  }

  Color get backgroundColor {
    switch (this) {
      case KycStatus.verified:
        return AppColors.successBg;
      case KycStatus.inReview:
      case KycStatus.pending:
        return AppColors.warningBg;
      case KycStatus.rejected:
        return AppColors.dangerBg;
      case KycStatus.notSubmitted:
        return AppColors.borderLight;
    }
  }
}
