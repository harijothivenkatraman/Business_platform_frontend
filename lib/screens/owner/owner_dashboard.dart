import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});
  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  Map<String, dynamic> _stats = {};
  List<dynamic> _members = [];
  List<dynamic> _trainers = [];
  List<dynamic> _kycPending = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final auth = context.read<AuthProvider>();
      final bid = auth.businessId;
      final statsRes = await ApiService.get('/businesses/$bid/stats');
      final membersRes = await ApiService.get('/businesses/$bid/members');
      final trainersRes = await ApiService.get('/businesses/$bid/trainers');
      final kycRes = await ApiService.get('/kyc/pending');
      setState(() {
        _stats = statsRes['data'] ?? {};
        _members = membersRes['data'] ?? [];
        _trainers = trainersRes['data'] ?? [];
        _kycPending = kycRes['data'] ?? [];
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
        Text('Dashboard', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        _buildStatsGrid(),
        const SizedBox(height: 24),
        if (_kycPending.isNotEmpty) ...[
          Text('Pending KYC Reviews (${_kycPending.length})',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ..._kycPending.map((k) => Card(
                child: ListTile(
                  leading:
                      const Icon(Icons.verified_user, color: Colors.orange),
                  title: Text(
                      'User: ${k['userId']?.toString().substring(0, 8) ?? 'N/A'}'),
                  subtitle:
                      Text('Status: ${k['status']} • ${k['documentType']}'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => _reviewKyc(k['id'], 'verified')),
                    IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => _reviewKyc(k['id'], 'rejected')),
                  ]),
                ),
              )),
          const SizedBox(height: 24),
        ],
        Text('Members (${_members.length})',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._members.map((m) => Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(m['name']?[0] ?? '?')),
                title: Text(m['name'] ?? ''),
                subtitle: Text('${m['email']} • KYC: ${m['kycStatus']}'),
              ),
            )),
        const SizedBox(height: 16),
        Text('Trainers (${_trainers.length})',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ..._trainers.map((t) => Card(
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Text(t['name']?[0] ?? '?')),
                title: Text(t['name'] ?? ''),
                subtitle: Text(t['email'] ?? ''),
              ),
            )),
      ]),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.8,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _statCard('Members', '${_stats['totalMembers'] ?? 0}', Icons.people,
            Colors.blue),
        _statCard('Trainers', '${_stats['totalTrainers'] ?? 0}', Icons.sports,
            Colors.teal),
        _statCard('Bookings', '${_stats['totalBookings'] ?? 0}',
            Icons.calendar_today, Colors.orange),
        _statCard('Revenue', '₹${_stats['totalRevenue'] ?? 0}',
            Icons.currency_rupee, Colors.green),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(value,
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(color: color.withOpacity(0.8))),
            ]),
      ),
    );
  }

  Future<void> _reviewKyc(String id, String status) async {
    try {
      await ApiService.put('/kyc/$id/review', {'status': status});
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('KYC $status')));
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
