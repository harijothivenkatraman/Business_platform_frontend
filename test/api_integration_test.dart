import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:business_platform/services/api_service.dart';

class _RealHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  HttpOverrides.global = _RealHttpOverrides();

  test('P1 Live AWS Server Health Check', () async {
    final res = await ApiService.get('/health');
    expect(res['status'], 'ok');
    expect(res['service'], 'business-platform');
  });

  test('P1 Live AWS Full Auth & Multi-tenant Flow', () async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ownerEmail = 'owner_$timestamp@test.com';

    // 1. Register Owner (auto-creates business)
    final ownerRes = await ApiService.post('/auth/register', {
      'name': 'Test Owner',
      'email': ownerEmail,
      'password': 'password123',
      'role': 'owner',
    });
    expect(ownerRes['success'], true);
    final businessId = ownerRes['data']['user']['businessId'];
    expect(businessId, isNotNull);

    // 2. Register Member with businessId
    final memberEmail = 'member_$timestamp@test.com';
    final memberRes = await ApiService.post('/auth/register', {
      'name': 'Test Member',
      'email': memberEmail,
      'password': 'password123',
      'role': 'member',
      'businessId': businessId,
    });
    expect(memberRes['success'], true);

    // 3. Login as Member
    final loginRes = await ApiService.post('/auth/login', {
      'email': memberEmail,
      'password': 'password123',
    });
    expect(loginRes['success'], true);
    expect(loginRes['data']['accessToken'], isNotNull);
    expect(loginRes['data']['user']['role'], 'member');
  });
}
