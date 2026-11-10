import 'package:flutter_application_massage/data/massage_mock_data.dart';

class BookingDraft {
  const BookingDraft({
    this.isActive = false,
    this.service,
    this.date,
    this.time,
    this.customerName,
    this.awaitingConfirmation = false,
  });

  final bool isActive;
  final MassageService? service;
  final DateTime? date;
  final String? time;
  final String? customerName;
  final bool awaitingConfirmation;

  bool get isComplete =>
      service != null && date != null && time != null && customerName != null;

  BookingDraft copyWith({
    bool? isActive,
    MassageService? service,
    DateTime? date,
    String? time,
    String? customerName,
    bool? awaitingConfirmation,
  }) {
    return BookingDraft(
      isActive: isActive ?? this.isActive,
      service: service ?? this.service,
      date: date ?? this.date,
      time: time ?? this.time,
      customerName: customerName ?? this.customerName,
      awaitingConfirmation: awaitingConfirmation ?? this.awaitingConfirmation,
    );
  }
}

class DemoBooking {
  const DemoBooking({
    required this.id,
    required this.customerName,
    required this.service,
    required this.date,
    required this.time,
  });

  final String id;
  final String customerName;
  final MassageService service;
  final DateTime date;
  final String time;
}

class DemoBookingStore {
  DemoBookingStore._();

  static final List<DemoBooking> bookings = [];

  static void add(DemoBooking booking) {
    if (bookings.any((existing) => existing.id == booking.id)) return;
    bookings.add(booking);
  }
}
