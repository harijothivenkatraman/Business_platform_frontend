import 'package:flutter/material.dart';
import '../../models/plan.dart';
import '../../repositories/plan_repository.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/b2b_empty_state.dart';

class ManagePlansScreen extends StatefulWidget {
  final IPlanRepository? planRepository;
  const ManagePlansScreen({super.key, this.planRepository});

  @override
  State<ManagePlansScreen> createState() => _ManagePlansScreenState();
}

class _ManagePlansScreenState extends State<ManagePlansScreen> {
  late final IPlanRepository _repo;
  List<SubscriptionPlan> _plans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _repo = widget.planRepository ?? PlanRepository();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _loading = true);
    try {
      final plans = await _repo.getPlans();
      setState(() {
        _plans = plans;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Stack(
      children: [
        RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadPlans,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Subscription Plans', style: AppTextStyles.h1),
                      const SizedBox(height: 4),
                      Text('Configure membership packages and recurring tiers.',
                          style: AppTextStyles.subtitle),
                    ],
                  ),
                  FilledButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Plan'),
                    onPressed: _showCreateDialog,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_plans.isEmpty)
                B2BEmptyState(
                  icon: Icons.card_membership,
                  title: 'No Subscription Plans',
                  subtitle: 'Create membership plans to allow members to subscribe.',
                  actionLabel: 'Create Plan',
                  onAction: _showCreateDialog,
                )
              else
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isMultiCol = constraints.maxWidth > 800;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: _plans.map((p) {
                        final cardWidth = isMultiCol
                            ? (constraints.maxWidth - 16) / 2
                            : constraints.maxWidth;
                        return SizedBox(
                          width: cardWidth,
                          child: _buildPlanCard(p),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(plan.name, style: AppTextStyles.h2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${plan.duration} ${plan.durationUnit.toUpperCase()}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (plan.description.isNotEmpty)
            Text(plan.description, style: AppTextStyles.subtitle),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '₹',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                plan.price.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text('/ ${plan.durationUnit}', style: AppTextStyles.caption),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Included Features',
            style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (plan.features.isEmpty)
            const Text('• Standard club access', style: AppTextStyles.body)
          else
            ...plan.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 18, color: AppColors.success),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(f, style: AppTextStyles.body),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final featuresCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Create Subscription Plan'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Plan Name *',
                  hintText: 'e.g. Executive Club',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceCtrl,
                decoration: const InputDecoration(
                  labelText: 'Price (₹) *',
                  hintText: 'e.g. 2499',
                  prefixText: '₹ ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Access to premium amenities and personal coaching',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: featuresCtrl,
                decoration: const InputDecoration(
                  labelText: 'Features (comma separated)',
                  hintText: 'Unlimited gym, Sauna, 2 PT sessions/mo',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || priceCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Name and Price are required')),
                );
                return;
              }

              try {
                final features = featuresCtrl.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final nav = Navigator.of(ctx);
                final scaffold = ScaffoldMessenger.of(context);
                await _repo.createPlan(
                  name: nameCtrl.text.trim(),
                  price: double.tryParse(priceCtrl.text) ?? 0.0,
                  description: descCtrl.text.trim(),
                  features: features,
                );

                nav.pop();
                _loadPlans();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('$e')));
                }
              }
            },
            child: const Text('Publish Plan'),
          ),
        ],
      ),
    );
  }
}
