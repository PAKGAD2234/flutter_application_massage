import 'package:flutter_application_massage/view/model/booking_draft_model.dart';

enum ChatMessageRole { user, assistant }

class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.role,
    this.bookingConfirmation,
  });

  final String text;
  final ChatMessageRole role;
  final DemoBooking? bookingConfirmation;

  bool get isFromUser => role == ChatMessageRole.user;
}
