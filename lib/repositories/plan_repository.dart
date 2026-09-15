import '../models/plan.dart';
import '../services/api_service.dart';

abstract class IPlanRepository {
  Future<List<SubscriptionPlan>> getPlans();
  Future<SubscriptionPlan> createPlan({
    required String name,
    required double price,
    String? description,
    int duration = 1,
    String durationUnit = 'month',
    List<String> features = const [],
  });
  Future<Map<String, dynamic>> createOrder(String planId);
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    String signature = 'client-verified',
  });
}

class PlanRepository implements IPlanRepository {
  @override
  Future<List<SubscriptionPlan>> getPlans() async {
    final res = await ApiService.get('/plans');
    final list = (res['data'] as List?) ?? [];
    return list.map((p) => SubscriptionPlan.fromJson(p as Map<String, dynamic>)).toList();
  }

  @override
  Future<SubscriptionPlan> createPlan({
    required String name,
    required double price,
    String? description,
    int duration = 1,
    String durationUnit = 'month',
    List<String> features = const [],
  }) async {
    final res = await ApiService.post('/plans', {
      'name': name,
      'price': price,
      'description': description ?? '',
      'duration': duration,
      'durationUnit': durationUnit,
      'features': features,
    });
    return SubscriptionPlan.fromJson(res['data']);
  }

  @override
  Future<Map<String, dynamic>> createOrder(String planId) async {
    final res = await ApiService.post('/subscriptions/create-order', {'planId': planId});
    return res['data'] as Map<String, dynamic>;
  }

  @override
  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    String signature = 'client-verified',
  }) async {
    await ApiService.post('/subscriptions/verify-payment', {
      'orderId': orderId,
      'paymentId': paymentId,
      'signature': signature,
    });
  }
}
