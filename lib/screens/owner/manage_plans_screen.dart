import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ManagePlansScreen extends StatefulWidget {
  const ManagePlansScreen({super.key});
  @override
  State<ManagePlansScreen> createState() => _ManagePlansScreenState();
}

class _ManagePlansScreenState extends State<ManagePlansScreen> {
  List<dynamic> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/plans');
      setState(() {
        _plans = res['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Plans')),
      floatingActionButton: FloatingActionButton(
          onPressed: _showCreateDialog, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _plans.isEmpty
              ? const Center(child: Text('No plans yet. Create one!'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _plans.length,
                  itemBuilder: (ctx, i) {
                    final p = _plans[i];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                            child: Text('₹'),
                            backgroundColor: Colors.green.shade100),
                        title: Text(p['name'] ?? ''),
                        subtitle: Text(
                            '₹${p['price']} / ${p['duration']} ${p['durationUnit'] ?? 'month'}'),
                        trailing: Text(
                            '${(p['features'] as List?)?.length ?? 0} features'),
                      ),
                    );
                  },
                ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Plan'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Plan Name')),
          const SizedBox(height: 8),
          TextField(
              controller: priceCtrl,
              decoration: const InputDecoration(labelText: 'Price (₹)'),
              keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description')),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await ApiService.post('/plans', {
                  'name': nameCtrl.text,
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'description': descCtrl.text,
                  'duration': 1,
                  'durationUnit': 'month',
                });
                if (ctx.mounted) Navigator.pop(ctx);
                _loadPlans();
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}
