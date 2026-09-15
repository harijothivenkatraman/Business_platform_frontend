import 'kyc_status.dart';

class KycRecord {
  final String id;
  final String userId;
  final String? userName;
  final String? userEmail;
  final String documentType;
  final String? documentUrl;
  final KycStatus status;
  final String? reviewNotes;
  final DateTime? submittedAt;

  const KycRecord({
    required this.id,
    required this.userId,
    this.userName,
    this.userEmail,
    required this.documentType,
    this.documentUrl,
    required this.status,
    this.reviewNotes,
    this.submittedAt,
  });

  factory KycRecord.fromJson(Map<String, dynamic> json) {
    return KycRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'],
      userEmail: json['userEmail'],
      documentType: json['documentType'] ?? 'id_proof',
      documentUrl: json['documentPath'] ?? json['documentUrl'],
      status: KycStatus.fromString(json['status']),
      reviewNotes: json['reviewNotes'],
      submittedAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
