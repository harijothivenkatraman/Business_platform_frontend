import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../repositories/booking_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/b2b_empty_state.dart';
import '../../widgets/b2b_status_badge.dart';

class TrainerDashboard extends StatefulWidget {
  final IBookingRepository? bookingRepository;
  const TrainerDashboard({super.key, this.bookingRepository});

  @override
  State<TrainerDashboard> createState() => _TrainerDashboardState();
}

class _TrainerDashboardState extends State<TrainerDashboard> {
  late final IBookingRepository _repo;
  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.bookingRepository ?? BookingRepository();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    try {
      final list = await _repo.getBookings();
      setState(() {
        _bookings = list;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _bookings.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadBookings,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Trainer Schedule', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text('Manage your training sessions and slot availability.',
                      style: AppTextStyles.subtitle),
                ],
              ),
              FilledButton.icon(
                icon: const Icon(Icons.schedule, size: 18),
                label: const Text('Set Availability'),
                onPressed: _showAvailabilityDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Sessions
          Text('Booked Sessions (${_bookings.length})', style: AppTextStyles.h2),
          const SizedBox(height: 12),
          if (_bookings.isEmpty)
            B2BEmptyState(
              icon: Icons.calendar_month_outlined,
              title: 'No Sessions Booked',
              subtitle: 'When members schedule appointments, they will appear here.',
              actionLabel: 'Set Slot Availability',
              onAction: _showAvailabilityDialog,
            )
          else
            ..._bookings.map((b) => _buildSessionCard(b)),
        ],
      ),
    );
  }

  Widget _buildSessionCard(Booking b) {
    final isConfirmed = b.status == 'confirmed';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isConfirmed
                    ? AppColors.success.withOpacity(0.12)
                    : AppColors.borderLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isConfirmed ? Icons.event_available : Icons.event_busy,
                color: isConfirmed ? AppColors.success : AppColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${b.date} • ${b.startTime} - ${b.endTime}',
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Member: ${b.memberName ?? b.memberId}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            B2BStatusBadge(status: b.status),
            if (isConfirmed) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.cancel_outlined, size: 20, color: AppColors.danger),
                tooltip: 'Cancel session',
                onPressed: () => _cancel(b.id),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAvailabilityDialog() {
    final dateCtrl = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0],
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(
                labelText: 'Target Date (YYYY-MM-DD)',
                prefixIcon: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Default active intervals:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 6),
            const Text('• 09:00 - 10:00 (1:1)\n• 10:00 - 11:00 (1:1)\n• 11:00 - 12:00 (1:1)\n• 14:00 - 15:00 (1:1)\n• 15:00 - 16:00 (1:1)',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await _repo.setAvailability(
                  date: dateCtrl.text.trim(),
                  slots: [
                    {'startTime': '09:00', 'endTime': '10:00', 'capacity': 1},
                    {'startTime': '10:00', 'endTime': '11:00', 'capacity': 1},
                    {'startTime': '11:00', 'endTime': '12:00', 'capacity': 1},
                    {'startTime': '14:00', 'endTime': '15:00', 'capacity': 1},
                    {'startTime': '15:00', 'endTime': '16:00', 'capacity': 1},
                  ],
                );
                if (ctx.mounted) Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Availability slots published successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Publish Slots'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(String id) async {
    try {
      await _repo.cancelBooking(id);
      _loadBookings();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }
}
