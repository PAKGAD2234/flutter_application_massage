import 'dart:convert';

import 'package:flutter_application_massage/view/model/chat_message_model.dart';
import 'package:flutter_application_massage/view/service/gemini_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'sends the system instruction and parses Gemini text response',
    () async {
      late Map<String, dynamic> requestBody;
      late http.Request capturedRequest;
      final client = MockClient((request) async {
        capturedRequest = request;
        requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'สวัสดีค่ะ'},
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

      final reply = await service.generateReply(
        history: const [
          ChatMessage(text: 'ช่วยแนะนำบริการ', role: ChatMessageRole.user),
          ChatMessage(text: 'ได้ค่ะ', role: ChatMessageRole.assistant),
          ChatMessage(text: 'มีราคาเท่าไร', role: ChatMessageRole.user),
          ChatMessage(text: 'มีข้อมูลอะไรบ้าง', role: ChatMessageRole.user),
        ],
      );

      expect(reply, 'สวัสดีค่ะ');
      expect(capturedRequest.url.path, contains('gemini-3.6-flash'));
      expect(capturedRequest.headers['x-goog-api-key'], 'test-key');
      expect(capturedRequest.url.query, isEmpty);
      expect(requestBody['system_instruction'], isNotNull);
      expect(
        requestBody['generationConfig']['maxOutputTokens'],
        greaterThanOrEqualTo(1024),
      );
      final contents = requestBody['contents'] as List<dynamic>;
      expect(contents.map((turn) => turn['role']), ['user', 'model', 'user']);
      expect(
        contents.last['parts'].first['text'],
        'มีราคาเท่าไร\nมีข้อมูลอะไรบ้าง',
      );
      expect(service.systemInstruction, contains('นวดไทย 60 นาที'));
      expect(service.systemInstruction, contains('350 บาท'));
    },
  );

  test('includes booking context in system instruction', () async {
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
                    {'text': 'ยินดีเลยค่ะ'},
                  ],
                },
              },
            ],
          }),
        ),
        200,
      );
    });
    final service = GeminiService(client: client, apiKey: 'test-key');
    addTearDown(client.close);

    await service.generateReply(
      history: const [
        ChatMessage(text: 'จองให้หน่อย', role: ChatMessageRole.user),
      ],
      bookingContext: 'ขั้นตอนถัดไปที่แอปต้องการ: เลือกบริการ',
    );

    final instruction =
        requestBody['system_instruction']['parts'].first['text'] as String;
    expect(instruction, contains('ขั้นตอนถัดไปที่แอปต้องการ: เลือกบริการ'));
  });

  test('includes the Gemini error reason for non-success responses', () async {
    final client = MockClient(
      (request) async => http.Response(
        jsonEncode({
          'error': {'message': 'Model not found'},
        }),
        404,
      ),
    );
    final service = GeminiService(client: client, apiKey: 'test-key');
    addTearDown(client.close);

    await expectLater(
      service.generateReply(
        history: const [
          ChatMessage(text: 'สวัสดี', role: ChatMessageRole.user),
        ],
      ),
      throwsA(
        isA<GeminiServiceException>()
            .having((error) => error.message, 'message', contains('404'))
            .having(
              (error) => error.message,
              'message',
              contains('Model not found'),
            ),
      ),
    );
  });

  test(
    'retries temporary 503 errors and returns the complete response',
    () async {
      var requestCount = 0;
      final client = MockClient((request) async {
        requestCount++;
        if (requestCount == 1) return http.Response('busy', 503);
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'candidates': [
                {
                  'content': {
                    'parts': [
                      {'text': 'ยินดีค่ะ 😊'},
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

      final reply = await service.generateReply(
        history: const [
          ChatMessage(text: 'อยากจองคิวค่ะ', role: ChatMessageRole.user),
        ],
      );

      expect(requestCount, 2);
      expect(reply, 'ยินดีค่ะ 😊');
    },
  );

  test('cleans Markdown formatting from assistant replies', () async {
    final client = MockClient(
      (request) async => http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'candidates': [
              {
                'content': {
                  'parts': [
                    {'text': '**นวดน้ำมัน**\n* เวลา: 11:00 น.\n# ยินดีค่ะ'},
                  ],
                },
              },
            ],
          }),
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
    final service = GeminiService(client: client, apiKey: 'test-key');
    addTearDown(client.close);

    final reply = await service.generateReply(
      history: const [
        ChatMessage(text: 'มีบริการอะไรคะ', role: ChatMessageRole.user),
      ],
    );

    expect(reply, 'นวดน้ำมัน\n• เวลา: 11:00 น.\nยินดีค่ะ');
  });

  test('rejects a response truncated by the model token limit', () async {
    final client = MockClient(
      (request) async => http.Response.bytes(
        utf8.encode(
          jsonEncode({
            'candidates': [
              {
                'finishReason': 'MAX_TOKENS',
                'content': {
                  'parts': [
                    {'text': 'ข้อความที่ยังไม่จบ'},
                  ],
                },
              },
            ],
          }),
        ),
        200,
      ),
    );
    final service = GeminiService(client: client, apiKey: 'test-key');
    addTearDown(client.close);

    await expectLater(
      service.generateReply(
        history: const [
          ChatMessage(text: 'ช่วยแนะนำบริการ', role: ChatMessageRole.user),
        ],
      ),
      throwsA(
        isA<GeminiServiceException>().having(
          (error) => error.message,
          'message',
          contains('ยาวเกินกำหนด'),
        ),
      ),
    );
  });
}
