import '../models/dashboard_stats.dart';
import '../models/member.dart';
import '../models/trainer.dart';
import '../services/api_service.dart';

abstract class IBusinessRepository {
  Future<DashboardStats> getStats(String businessId);
  Future<List<Member>> getMembers(String businessId);
  Future<List<Trainer>> getTrainers(String businessId);
}

class BusinessRepository implements IBusinessRepository {
  @override
  Future<DashboardStats> getStats(String businessId) async {
    final res = await ApiService.get('/businesses/$businessId/stats');
    final data = (res['data'] as Map<String, dynamic>?) ?? {};
    return DashboardStats.fromJson(data);
  }

  @override
  Future<List<Member>> getMembers(String businessId) async {
    final res = await ApiService.get('/businesses/$businessId/members');
    final list = (res['data'] as List?) ?? [];
    return list.map((m) => Member.fromJson(m as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<Trainer>> getTrainers(String businessId) async {
    final res = await ApiService.get('/businesses/$businessId/trainers');
    final list = (res['data'] as List?) ?? [];
    return list.map((t) => Trainer.fromJson(t as Map<String, dynamic>)).toList();
  }
}
