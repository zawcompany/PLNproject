import '../models/booking_model.dart';

class BookingData {
  static List<BookingModel> bookings = [

    BookingModel(
      roomName: "Bougenville 1.1",
      start: DateTime(2026, 2, 18),
      end: DateTime(2026, 2, 25),
    ),

    BookingModel(
      roomName: "Kelas A1",
      start: DateTime(2026, 2, 19),
      end: DateTime(2026, 2, 19, 23, 59),
    ),

    BookingModel(
      roomName: "Gladiol 105",
      start: DateTime(2026, 2, 10),
      end: DateTime(2026, 2, 28),
    ),

  ];
}
