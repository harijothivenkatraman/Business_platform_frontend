import '../models/booking.dart';
import '../services/api_service.dart';

abstract class IBookingRepository {
  Future<List<Booking>> getBookings();
  Future<Booking> createBooking({
    required String trainerId,
    required String date,
    required String slotId,
  });
  Future<void> cancelBooking(String bookingId);
  Future<void> setAvailability({
    required String date,
    required List<Map<String, dynamic>> slots,
  });
}

class BookingRepository implements IBookingRepository {
  @override
  Future<List<Booking>> getBookings() async {
    final res = await ApiService.get('/bookings');
    final list = (res['data'] as List?) ?? [];
    return list.map((b) => Booking.fromJson(b as Map<String, dynamic>)).toList();
  }

  @override
  Future<Booking> createBooking({
    required String trainerId,
    required String date,
    required String slotId,
  }) async {
    final res = await ApiService.post('/bookings', {
      'trainerId': trainerId,
      'date': date,
      'slotId': slotId,
    });
    return Booking.fromJson(res['data']);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await ApiService.put('/bookings/$bookingId/cancel', {});
  }

  @override
  Future<void> setAvailability({
    required String date,
    required List<Map<String, dynamic>> slots,
  }) async {
    await ApiService.post('/bookings/trainers/availability', {
      'date': date,
      'slots': slots,
    });
  }
}
