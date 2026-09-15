import '../models/kyc_record.dart';
import '../models/kyc_status.dart';
import '../services/api_service.dart';

abstract class IKycRepository {
  Future<List<KycRecord>> getPendingReviews();
  Future<void> reviewKyc(String id, String status, {String? notes});
  Future<KycStatus> getMyStatus();
  Future<void> submitKyc({required String documentType, String? documentUrl});
}

class KycRepository implements IKycRepository {
  @override
  Future<List<KycRecord>> getPendingReviews() async {
    final res = await ApiService.get('/kyc/pending');
    final list = (res['data'] as List?) ?? [];
    return list.map((k) => KycRecord.fromJson(k as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> reviewKyc(String id, String status, {String? notes}) async {
    await ApiService.put('/kyc/$id/review', {
      'status': status,
      if (notes != null) 'reviewNotes': notes,
    });
  }

  @override
  Future<KycStatus> getMyStatus() async {
    final res = await ApiService.get('/kyc/status');
    final data = res['data'] as Map<String, dynamic>?;
    return KycStatus.fromString(data?['status']);
  }

  @override
  Future<void> submitKyc({required String documentType, String? documentUrl}) async {
    await ApiService.post('/kyc/submit', {
      'documentType': documentType,
      'documentUrl': documentUrl ?? 'pending_upload',
    });
  }
}
