class Trainer {
  final String id;
  final String name;
  final String email;
  final String? specialization;
  final int activeClientsCount;

  const Trainer({
    required this.id,
    required this.name,
    required this.email,
    this.specialization,
    this.activeClientsCount = 0,
  });

  factory Trainer.fromJson(Map<String, dynamic> json) {
    return Trainer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      specialization: json['specialization'] ?? 'Fitness Trainer',
      activeClientsCount: json['activeClientsCount'] ?? 0,
    );
  }
}
