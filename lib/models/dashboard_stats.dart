class DashboardStats {
  final int totalMembers;
  final int totalTrainers;
  final int totalBookings;
  final int activeSubscriptions;
  final double totalRevenue;
  final int pendingKyc;
  final double memberGrowthPct;
  final double revenueGrowthPct;

  const DashboardStats({
    this.totalMembers = 0,
    this.totalTrainers = 0,
    this.totalBookings = 0,
    this.activeSubscriptions = 0,
    this.totalRevenue = 0.0,
    this.pendingKyc = 0,
    this.memberGrowthPct = 12.5,
    this.revenueGrowthPct = 8.4,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalMembers: json['totalMembers'] ?? 0,
      totalTrainers: json['totalTrainers'] ?? 0,
      totalBookings: json['totalBookings'] ?? 0,
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingKyc: json['pendingKyc'] ?? 0,
      memberGrowthPct: (json['memberGrowthPct'] as num?)?.toDouble() ?? 12.5,
      revenueGrowthPct: (json['revenueGrowthPct'] as num?)?.toDouble() ?? 8.4,
    );
  }
}
