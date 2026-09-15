import 'kyc_status.dart';

class Member {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final KycStatus kycStatus;
  final String? activePlanName;
  final DateTime? joinedAt;

  const Member({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.kycStatus,
    this.activePlanName,
    this.joinedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      kycStatus: KycStatus.fromString(json['kycStatus']),
      activePlanName: json['activePlanName'],
      joinedAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
