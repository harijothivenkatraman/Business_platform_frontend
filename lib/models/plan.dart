class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String durationUnit;
  final List<String> features;
  final bool isPopular;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    required this.durationUnit,
    required this.features,
    this.isPopular = false,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlan(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      duration: json['duration'] ?? 1,
      durationUnit: json['durationUnit'] ?? 'month',
      features: (json['features'] as List?)?.map((e) => e.toString()).toList() ?? [],
      isPopular: json['isPopular'] ?? false,
    );
  }
}
