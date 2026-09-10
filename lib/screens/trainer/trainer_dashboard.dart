import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class TrainerDashboard extends StatefulWidget {
  const TrainerDashboard({super.key});
  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    try {
      final res = await ApiService.get('/bookings');
      setState(() {
        _bookings = res['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(padding: const EdgeInsets.all(16), children: [
              Text('My Sessions',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              _buildAvailabilityButton(),
              const SizedBox(height: 16),
              if (_bookings.isEmpty)
                const Center(
                    child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No bookings yet')))
              else
                ..._bookings.map((b) => Card(
                      child: ListTile(
                        leading: Icon(
                          b['status'] == 'confirmed'
                              ? Icons.event_available
                              : Icons.event_busy,
                          color: b['status'] == 'confirmed'
                              ? Colors.green
                              : Colors.grey,
                        ),
                        title: Text(
                            '${b['date']} • ${b['startTime']} - ${b['endTime']}'),
                        subtitle: Text('Status: ${b['status']}'),
                        trailing: b['status'] == 'confirmed'
                            ? TextButton(
                                onPressed: () => _cancel(b['id']),
                                child: const Text('Cancel'))
                            : null,
                      ),
                    )),
            ]),
    );
  }

  Widget _buildAvailabilityButton() {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: ListTile(
        leading: const Icon(Icons.schedule),
        title: const Text('Set Availability'),
        subtitle: const Text('Configure your available time slots'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: _showAvailabilityDialog,
      ),
    );
  }

  void _showAvailabilityDialog() {
    final dateCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().split('T')[0]);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Availability'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: dateCtrl,
              decoration:
                  const InputDecoration(labelText: 'Date (YYYY-MM-DD)')),
          const SizedBox(height: 8),
          const Text('Default slots: 9-10, 10-11, 11-12, 14-15, 15-16',
              style: TextStyle(fontSize: 12)),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await ApiService.post('/bookings/trainers/availability', {
                  'date': dateCtrl.text,
                  'slots': [
                    {'startTime': '09:00', 'endTime': '10:00', 'capacity': 1},
                    {'startTime': '10:00', 'endTime': '11:00', 'capacity': 1},
                    {'startTime': '11:00', 'endTime': '12:00', 'capacity': 1},
                    {'startTime': '14:00', 'endTime': '15:00', 'capacity': 1},
                    {'startTime': '15:00', 'endTime': '16:00', 'capacity': 1},
                  ],
                });
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Availability set!')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(String id) async {
    try {
      await ApiService.put('/bookings/$id/cancel', {});
      _loadBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
