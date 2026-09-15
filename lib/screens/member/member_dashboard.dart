import 'package:flutter/material.dart';
import '../../models/booking.dart';
import '../../models/kyc_status.dart';
import '../../models/plan.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/kyc_repository.dart';
import '../../repositories/plan_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/b2b_empty_state.dart';
import '../../widgets/b2b_status_badge.dart';

class MemberDashboard extends StatefulWidget {
  final IKycRepository? kycRepository;
  final IPlanRepository? planRepository;
  final IBookingRepository? bookingRepository;

  const MemberDashboard({
    super.key,
    this.kycRepository,
    this.planRepository,
    this.bookingRepository,
  });

  @override
  State<MemberDashboard> createState() => _MemberDashboardState();
}

class _MemberDashboardState extends State<MemberDashboard> {
  late final IKycRepository _kycRepo;
  late final IPlanRepository _planRepo;
  late final IBookingRepository _bookingRepo;

  KycStatus _kycStatus = KycStatus.notSubmitted;
  List<SubscriptionPlan> _plans = [];
  List<Booking> _bookings = [];
  Map<String, dynamic>? _subscription;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _kycRepo = widget.kycRepository ?? KycRepository();
    _planRepo = widget.planRepository ?? PlanRepository();
    _bookingRepo = widget.bookingRepository ?? BookingRepository();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _kycRepo.getMyStatus().catchError((_) => KycStatus.notSubmitted),
        _planRepo.getPlans().catchError((_) => <SubscriptionPlan>[]),
        _bookingRepo.getBookings().catchError((_) => <Booking>[]),
      ]);

      if (mounted) {
        setState(() {
          _kycStatus = results[0] as KycStatus;
          _plans = results[1] as List<SubscriptionPlan>;
          _bookings = results[2] as List<Booking>;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _plans.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Member Portal', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text('Access your membership benefits, sessions, and verification.',
                      style: AppTextStyles.subtitle),
                ],
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Book Session'),
                onPressed: _showBookingDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KYC Status Banner
          _buildKycCard(),
          const SizedBox(height: 16),

          // Active Subscription Card
          _buildSubscriptionCard(),
          const SizedBox(height: 24),

          // Membership Plans Section
          _buildPlansSection(),
          const SizedBox(height: 32),

          // My Bookings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('My Booked Sessions (${_bookings.length})', style: AppTextStyles.h2),
            ],
          ),
          const SizedBox(height: 12),
          if (_bookings.isEmpty)
            B2BEmptyState(
              icon: Icons.event_available_outlined,
              title: 'No Sessions Booked',
              subtitle: 'Schedule one-on-one sessions with our certified trainers.',
              actionLabel: 'Book First Session',
              onAction: _showBookingDialog,
            )
          else
            ..._bookings.map((b) => _buildBookingCard(b)),
        ],
      ),
    );
  }

  Widget _buildKycCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _kycStatus.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_rounded, color: _kycStatus.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KYC Verification Status', style: AppTextStyles.bodyMedium),
                const SizedBox(height: 2),
                Text(
                  _kycStatus == KycStatus.verified
                      ? 'Account fully verified and approved.'
                      : _kycStatus == KycStatus.pending || _kycStatus == KycStatus.inReview
                          ? 'Verification in progress by platform administration.'
                          : 'Identity proof required to unlock subscriptions.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (_kycStatus == KycStatus.notSubmitted || _kycStatus == KycStatus.rejected)
            FilledButton.icon(
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Submit KYC'),
              onPressed: _submitKyc,
            )
          else
            B2BStatusBadge.fromKyc(_kycStatus),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final hasActiveSub = _subscription != null;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: hasActiveSub ? AppColors.successBg : AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasActiveSub ? AppColors.success.withOpacity(0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasActiveSub
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.card_membership_rounded,
              color: hasActiveSub ? AppColors.success : AppColors.textMuted,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveSub ? (_subscription!['planName'] ?? 'Active Plan') : 'No Active Subscription',
                  style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  hasActiveSub
                      ? 'Status: Active • Auto-renews monthly'
                      : 'Explore subscription plans below to unlock full facility access.',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (hasActiveSub)
            const B2BStatusBadge(status: 'active', label: 'Active')
        ],
      ),
    );
  }

  Widget _buildPlansSection() {
    if (_kycStatus != KycStatus.verified) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_rounded, color: AppColors.textMuted, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Subscription Plans Locked', style: AppTextStyles.bodyMedium),
                  Text(
                    'Membership plans unlock once your KYC document is verified by administration.',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_plans.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Available Membership Plans', style: AppTextStyles.h2),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _plans.map((p) => _buildPlanPurchaseCard(p)).toList(),
        ),
      ],
    );
  }

  Widget _buildPlanPurchaseCard(SubscriptionPlan plan) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan.name, style: AppTextStyles.h3),
              Text('₹${plan.price.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 6),
          Text(plan.description, style: AppTextStyles.caption),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _subscribe(plan.id),
              child: const Text('Subscribe Now'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking b) {
    final isCancelled = b.status == 'cancelled';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCancelled ? AppColors.borderLight : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.event_note_rounded,
                color: isCancelled ? AppColors.textMuted : AppColors.primary,
                size: 20,
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
                  const SizedBox(height: 2),
                  Text(
                    'Trainer: ${b.trainerName ?? b.trainerId}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            B2BStatusBadge(status: b.status),
            const SizedBox(width: 8),
            if (!isCancelled)
              TextButton(
                onPressed: () => _cancelBooking(b.id),
                child: const Text('Cancel', style: TextStyle(color: AppColors.danger)),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitKyc() async {
    try {
      await _kycRepo.submitKyc(documentType: 'id_proof');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('KYC submitted for review!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _subscribe(String planId) async {
    try {
      final order = await _planRepo.createOrder(planId);
      await _planRepo.verifyPayment(
        orderId: order['orderId'],
        paymentId: 'pay_sim_${DateTime.now().millisecondsSinceEpoch}',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription successfully activated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  Future<void> _cancelBooking(String bookingId) async {
    try {
      await _bookingRepo.cancelBooking(bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking cancelled')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _showBookingDialog() {
    final dateCtrl = TextEditingController(
      text: DateTime.now().add(const Duration(days: 1)).toIso8601String().split('T')[0],
    );
    final trainerCtrl = TextEditingController(text: 'trainer-01');
    final slotCtrl = TextEditingController(text: '09:00 - 10:00');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Schedule Training Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(labelText: 'Date (YYYY-MM-DD) *', prefixIcon: Icon(Icons.calendar_today)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: trainerCtrl,
              decoration: const InputDecoration(labelText: 'Trainer ID / Name *', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: slotCtrl,
              decoration: const InputDecoration(labelText: 'Time Slot *', prefixIcon: Icon(Icons.access_time)),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                final nav = Navigator.of(ctx);
                await _bookingRepo.createBooking(
                  trainerId: trainerCtrl.text.trim(),
                  date: dateCtrl.text.trim(),
                  slotId: slotCtrl.text.trim(),
                );
                nav.pop();
                _loadData();
              } catch (e) {
                if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('Confirm Schedule'),
          ),
        ],
      ),
    );
  }
}
