import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class MemberDashboard extends StatefulWidget {
  const MemberDashboard({super.key});
  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  Map<String, dynamic>? _subscription;
  Map<String, dynamic>? _kycStatus;
  List<dynamic> _bookings = [];
  List<dynamic> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final subRes = await ApiService.get('/subscriptions/my');
      final kycRes = await ApiService.get('/kyc/status');
      final bookRes = await ApiService.get('/bookings');
      final planRes = await ApiService.get('/plans');
      setState(() {
        _subscription = subRes['data'];
        _kycStatus = kycRes['data'];
        _bookings = bookRes['data'] ?? [];
        _plans = planRes['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        Text('My Dashboard', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        _buildKycCard(),
        const SizedBox(height: 12),
        _buildSubscriptionCard(),
        const SizedBox(height: 12),
        if (_kycStatus?['status'] == 'verified') _buildPlansSection(),
        const SizedBox(height: 16),
        Text('My Bookings', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (_bookings.isEmpty)
          const Card(
              child: Padding(
                  padding: EdgeInsets.all(24), child: Text('No bookings yet')))
        else
          ..._bookings.map((b) => Card(
                child: ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(
                      '${b['date']} • ${b['startTime']} - ${b['endTime']}'),
                  subtitle: Text('Status: ${b['status']}'),
                ),
              )),
      ]),
    );
  }

  Widget _buildKycCard() {
    final status = _kycStatus?['status'] ?? 'not_submitted';
    final color = status == 'verified'
        ? Colors.green
        : status == 'rejected'
            ? Colors.red
            : Colors.orange;
    return Card(
      child: ListTile(
        leading: Icon(Icons.verified_user, color: color),
        title: const Text('KYC Verification'),
        subtitle: Text('Status: $status'),
        trailing: status == 'not_submitted' || status == 'rejected'
            ? FilledButton(onPressed: _submitKyc, child: const Text('Submit'))
            : Icon(Icons.check_circle, color: color),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    if (_subscription == null) {
      return Card(
        color: Colors.grey.shade100,
        child: const ListTile(
          leading: Icon(Icons.card_membership),
          title: Text('No Active Subscription'),
          subtitle: Text('Browse plans below to subscribe'),
        ),
      );
    }
    return Card(
      color: Colors.green.shade50,
      child: ListTile(
        leading: const Icon(Icons.card_membership, color: Colors.green),
        title: Text(_subscription!['planName'] ?? 'Active Plan'),
        subtitle: Text(
            'Status: ${_subscription!['status']} • Expires: ${_subscription!['endDate']?.toString().split('T')[0] ?? 'N/A'}'),
      ),
    );
  }

  Widget _buildPlansSection() {
    if (_plans.isEmpty) return const SizedBox();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Available Plans', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 8),
      ..._plans.map((p) => Card(
            child: ListTile(
              leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: const Icon(Icons.star)),
              title: Text(p['name'] ?? ''),
              subtitle: Text(
                  '₹${p['price']} / ${p['duration']} ${p['durationUnit'] ?? 'month'}'),
              trailing: FilledButton(
                  onPressed: () => _subscribe(p['id']),
                  child: const Text('Subscribe')),
            ),
          )),
    ]);
  }

  Future<void> _submitKyc() async {
    // Simplified KYC submission (without file for MVP)
    try {
      // For MVP, we'll submit a dummy KYC
      await ApiService.post('/kyc/submit', {'documentType': 'id_proof'})
          .catchError((_) {});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('KYC submitted for review')));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _subscribe(String planId) async {
    try {
      final orderRes = await ApiService.post(
          '/subscriptions/create-order', {'planId': planId});
      final order = orderRes['data'];
      // Simulate payment success
      await ApiService.post('/subscriptions/verify-payment', {
        'orderId': order['orderId'],
        'paymentId': 'pay_simulated_${DateTime.now().millisecondsSinceEpoch}',
        'signature': 'simulated',
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subscription activated!')));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
