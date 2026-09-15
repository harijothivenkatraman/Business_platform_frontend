class Booking {
  final String id;
  final String trainerId;
  final String? trainerName;
  final String memberId;
  final String? memberName;
  final String date;
  final String startTime;
  final String endTime;
  final String status;

  const Booking({
    required this.id,
    required this.trainerId,
    this.trainerName,
    required this.memberId,
    this.memberName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? '',
      trainerId: json['trainerId'] ?? '',
      trainerName: json['trainerName'],
      memberId: json['memberId'] ?? '',
      memberName: json['memberName'],
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '09:00',
      endTime: json['endTime'] ?? '10:00',
      status: json['status'] ?? 'confirmed',
    );
  }
}
