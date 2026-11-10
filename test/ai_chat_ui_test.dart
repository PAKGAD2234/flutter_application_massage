import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_massage/view/ai_chat_ui.dart';
import 'package:flutter_application_massage/view/model/booking_draft_model.dart';
import 'package:flutter_application_massage/view/my_booking_ui.dart';
import 'package:flutter_application_massage/view/service/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  Future<void> tapSend(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.arrow_upward_rounded));
    await tester.pumpAndSettle();
  }

  testWidgets('confirms a demo booking only after customer confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const AiChatUi(),
        routes: {'/my-booking': (_) => const MyBookingUi()},
      ),
    );

    await tester.tap(find.text('เริ่มจองนวดไทย 60 นาที'));
    await tester.pumpAndSettle();
    expect(find.textContaining('เลือกวันที่'), findsOneWidget);

    await tester.tap(find.text('พรุ่งนี้'));
    await tester.pumpAndSettle();
    expect(find.textContaining('เวลาใด'), findsOneWidget);

    await tester.tap(find.text('10:00'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ชื่อผู้จอง'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'ชื่อ สมชาย');
    await tapSend(tester);
    expect(find.textContaining('สรุปรายละเอียดการจองจำลอง'), findsOneWidget);
    expect(find.textContaining('Demo Booking Confirmed'), findsNothing);

    await tester.tap(find.text('ยืนยัน'));
    await tester.pumpAndSettle();
    expect(find.text('Demo Booking Confirmed'), findsOneWidget);
    expect(find.text('DEMO-0001'), findsOneWidget);
    expect(find.text('สมชาย'), findsOneWidget);
    expect(find.text('นวดไทย 60 นาที'), findsWidgets);
    expect(find.text('350 บาท'), findsOneWidget);
    expect(find.textContaining('ไม่ได้จองคิวจริง'), findsOneWidget);

    await tester.tap(find.text('การจอง'));
    await tester.pumpAndSettle();
    expect(find.text('การจองของฉัน'), findsNWidgets(2));
    expect(DemoBookingStore.bookings, hasLength(1));
    await tester.scrollUntilVisible(
      find.textContaining('DEMO-0001'),
      400,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('DEMO-0001'), findsOneWidget);
    expect(find.text('DEMO · ไม่ใช่คิวจริง'), findsOneWidget);
    expect(find.text('ผู้จอง: สมชาย'), findsOneWidget);
  });

  testWidgets('answers catalog price and duration from mock data', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AiChatUi()));

    await tester.tap(find.text('ขอดูบริการและราคา'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('นวดไทย 60 นาที — 60 นาที / 350 บาท'),
      findsOneWidget,
    );
    expect(
      find.textContaining('อโรม่า 90 นาที — 90 นาที / 650 บาท'),
      findsOneWidget,
    );
  });

  testWidgets('shows a retryable setup error when Gemini key is missing', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: AiChatUi()));

    await tester.tap(find.text('แนะนำบริการนวด'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('ยังไม่ได้ตั้งค่า Gemini API Key'),
      findsOneWidget,
    );
    expect(find.text('ลองอีกครั้ง'), findsOneWidget);
  });

  testWidgets('uses Gemini to respond naturally during booking', (
    tester,
  ) async {
    late Map<String, dynamic> requestBody;
    final client = MockClient((request) async {
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': 'ได้เลยค่ะ อยากนวดแบบไหนเป็นพิเศษคะ?'},
                  ],
                },
              },
            ],
          }),
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = GeminiService(client: client, apiKey: 'test-key');
    addTearDown(client.close);

    await tester.pumpWidget(
      MaterialApp(home: AiChatUi(geminiService: service)),
    );
    await tester.enterText(find.byType(TextField), 'ช่วยจองคิวให้หน่อยค่ะ');
    await tapSend(tester);

    expect(find.text('ได้เลยค่ะ อยากนวดแบบไหนเป็นพิเศษคะ?'), findsOneWidget);
    final instruction =
        requestBody['system_instruction']['parts'].first['text'] as String;
    expect(instruction, contains('ขั้นตอนถัดไปที่แอปต้องการ: เลือกบริการ'));
  });
}
