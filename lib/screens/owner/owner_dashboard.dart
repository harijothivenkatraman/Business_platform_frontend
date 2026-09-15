import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/member.dart';
import '../../models/trainer.dart';
import '../../providers/auth_provider.dart';
import '../../providers/business_dashboard_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/b2b_data_table.dart';
import '../../widgets/b2b_kyc_review_card.dart';
import '../../widgets/b2b_stat_card.dart';
import '../../widgets/b2b_status_badge.dart';

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  void _refreshData() {
    final bid = context.read<AuthProvider>().businessId;
    if (bid.isNotEmpty) {
      context.read<BusinessDashboardProvider>().loadDashboard(bid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<BusinessDashboardProvider>();

    if (dashboard.isLoading && dashboard.members.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => _refreshData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Enterprise Overview', style: AppTextStyles.h1),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time metrics, members, and verification requests.',
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh'),
                onPressed: _refreshData,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stat Cards Grid
          LayoutBuilder(
            builder: (ctx, constraints) {
              final crossAxisCount = constraints.maxWidth > 1100
                  ? 4
                  : constraints.maxWidth > 650
                      ? 2
                      : 1;

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: crossAxisCount == 4 ? 1.5 : 2.0,
                children: [
                  B2BStatCard(
                    title: 'Total Members',
                    value: '${dashboard.stats.totalMembers}',
                    icon: Icons.people_alt_rounded,
                    iconColor: AppColors.accent,
                    trend: dashboard.stats.memberGrowthPct,
                    trendLabel: 'vs last month',
                  ),
                  B2BStatCard(
                    title: 'Active Trainers',
                    value: '${dashboard.stats.totalTrainers}',
                    icon: Icons.fitness_center_rounded,
                    iconColor: AppColors.primary,
                    trend: 5.0,
                    trendLabel: 'staff capacity',
                  ),
                  B2BStatCard(
                    title: 'Completed Bookings',
                    value: '${dashboard.stats.totalBookings}',
                    icon: Icons.calendar_today_rounded,
                    iconColor: AppColors.success,
                    trend: 14.2,
                    trendLabel: 'sessions held',
                  ),
                  B2BStatCard(
                    title: 'Total Revenue',
                    value: '₹${dashboard.stats.totalRevenue.toStringAsFixed(0)}',
                    icon: Icons.currency_rupee_rounded,
                    iconColor: AppColors.warning,
                    trend: dashboard.stats.revenueGrowthPct,
                    trendLabel: 'ARR trajectory',
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 32),

          // Pending KYC Reviews Section
          if (dashboard.pendingKyc.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.verified_user_outlined, color: AppColors.warning, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Pending KYC Verifications (${dashboard.pendingKyc.length})',
                  style: AppTextStyles.h2,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...dashboard.pendingKyc.map((kyc) => B2BKYCReviewCard(
                  record: kyc,
                  onReview: (id, status, notes) async {
                    final ok = await dashboard.reviewKyc(id, status, notes: notes);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'KYC application $status' : 'Action failed'),
                          backgroundColor: status == 'verified' ? AppColors.success : AppColors.danger,
                        ),
                      );
                    }
                  },
                )),
            const SizedBox(height: 32),
          ],

          // Members Data Table
          B2BDataTable(
            title: 'Registered Members',
            searchHint: 'Search members by name or email...',
            columns: const [
              B2BDataTableColumn(title: 'Member', flex: 3),
              B2BDataTableColumn(title: 'Contact', flex: 3),
              B2BDataTableColumn(title: 'KYC Status', flex: 2),
            ],
            rows: dashboard.members.map((Member m) {
              return B2BDataTableRow(
                searchTerms: '${m.name} ${m.email}',
                cells: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.accent.withOpacity(0.15),
                        child: Text(
                          m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(m.name, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  Text(m.email, style: AppTextStyles.subtitle),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: B2BStatusBadge.fromKyc(m.kycStatus),
                  ),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // Trainers Data Table
          B2BDataTable(
            title: 'Training Staff',
            searchHint: 'Search trainers by name or spec...',
            columns: const [
              B2BDataTableColumn(title: 'Trainer', flex: 3),
              B2BDataTableColumn(title: 'Email', flex: 3),
              B2BDataTableColumn(title: 'Specialization', flex: 2),
            ],
            rows: dashboard.trainers.map((Trainer t) {
              return B2BDataTableRow(
                searchTerms: '${t.name} ${t.email} ${t.specialization}',
                cells: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: Text(
                          t.name.isNotEmpty ? t.name[0].toUpperCase() : 'T',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(t.name, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  Text(t.email, style: AppTextStyles.subtitle),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      t.specialization ?? 'Fitness Coach',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
