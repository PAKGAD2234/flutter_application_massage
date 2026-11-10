import 'package:flutter/material.dart';
import 'package:flutter_application_massage/data/massage_mock_data.dart';
import 'package:flutter_application_massage/view/model/booking_draft_model.dart';
import 'package:flutter_application_massage/view/model/chat_message_model.dart';
import 'package:flutter_application_massage/view/service/gemini_service.dart';
import 'package:google_fonts/google_fonts.dart';

class AiChatUi extends StatefulWidget {
  const AiChatUi({super.key, this.geminiService});

  final GeminiService? geminiService;

  @override
  State<AiChatUi> createState() => _AiChatUiState();
}

class _AiChatUiState extends State<AiChatUi> {
  static const _months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  static const _navigationRoutes = [
    '/home',
    '/booking',
    '/ai-chat',
    '/my-booking',
    '/profile',
  ];
  static int _nextDemoBookingNumber = 1;

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  late final GeminiService _geminiService =
      widget.geminiService ?? GeminiService();
  late final bool _ownsGeminiService = widget.geminiService == null;
  final List<ChatMessage> _messages = [];

  BookingDraft _bookingDraft = const BookingDraft();
  bool _isTyping = false;
  String? _requestError;
  BookingDraft? _retryBookingDraft;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    if (_ownsGeminiService) _geminiService.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? suggestion]) async {
    final text = (suggestion ?? _messageController.text).trim();
    if (text.isEmpty || _isTyping) return;

    setState(() {
      _messages.add(ChatMessage(text: text, role: ChatMessageRole.user));
      _messageController.clear();
      _requestError = null;
    });
    _scrollToBottom();

    if (_bookingDraft.isActive || _hasBookingIntent(text)) {
      await _advanceBookingConversation(text);
    } else if (_isCatalogQuestion(text)) {
      await _respondLocally(_catalogReply(text));
    } else {
      await _requestGeminiReply();
    }
  }

  bool _isCatalogQuestion(String text) => RegExp(
    r'ราคา|ค่าบริการ|กี่บาท|เท่าไร|เท่าไหร่|กี่นาที|ระยะเวลา|ใช้เวลานาน|ดูบริการ|มีบริการ|บริการอะไร|พนักงาน|หมอนวด|therapist|staff|service|price',
    caseSensitive: false,
  ).hasMatch(text);

  String _catalogReply(String text) {
    if (RegExp(
      r'พนักงาน|หมอนวด|therapist|staff',
      caseSensitive: false,
    ).hasMatch(text)) {
      return 'รายชื่อพนักงานตัวอย่าง: ${MassageMockData.staff.join(', ')}\n'
          'ข้อมูลนี้เป็น Mock Data และไม่มีข้อมูลเวลาว่างค่ะ';
    }

    final service = MassageMockData.findServiceMentionedIn(text);
    if (service != null) {
      return '${service.name} ใช้เวลา ${service.durationMinutes} นาที '
          'ราคา ${service.priceBaht} บาทค่ะ';
    }

    final matchingServices =
        MassageMockData.mentionsServiceType(text)
            ? MassageMockData.services.where(
              (item) => text
                  .replaceAll(' ', '')
                  .contains(item.name.split(' ').first.replaceAll(' ', '')),
            )
            : MassageMockData.services;
    final lines = matchingServices
        .map(
          (item) =>
              '• ${item.name} — ${item.durationMinutes} นาที / ${item.priceBaht} บาท',
        )
        .join('\n');
    return 'รายการบริการและราคาตัวอย่างมีดังนี้ค่ะ\n$lines';
  }

  Future<void> _respondLocally(String reply) async {
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;
    setState(() {
      _messages.add(ChatMessage(text: reply, role: ChatMessageRole.assistant));
      _isTyping = false;
    });
    _scrollToBottom();
  }

  bool _hasBookingIntent(String text) =>
      RegExp(r'จอง|นัดหมาย|booking|book', caseSensitive: false).hasMatch(text);

  Future<void> _requestGeminiReply({
    BookingDraft? bookingDraft,
    String? fallbackText,
  }) async {
    setState(() {
      _isTyping = true;
      _requestError = null;
      _retryBookingDraft = bookingDraft;
    });
    _scrollToBottom();

    try {
      final reply = await _geminiService.generateReply(
        history: _messages,
        bookingContext:
            bookingDraft == null ? null : _buildBookingContext(bookingDraft),
      );
      if (!mounted) return;
      setState(() {
        _messages.add(
          ChatMessage(text: reply, role: ChatMessageRole.assistant),
        );
        _isTyping = false;
        _requestError = null;
        _retryBookingDraft = null;
      });
    } on GeminiServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _requestError = error.message;
        if (fallbackText != null) {
          _messages.add(
            ChatMessage(text: fallbackText, role: ChatMessageRole.assistant),
          );
        }
        _isTyping = false;
      });
    } finally {
      if (mounted && _isTyping) {
        setState(() => _isTyping = false);
      }
    }
    _scrollToBottom();
  }

  String _buildBookingContext(BookingDraft draft) {
    final service = draft.service;
    final date = draft.date;
    final nextStep =
        service == null
            ? 'เลือกบริการที่ต้องการ'
            : date == null || !_isValidDate(date)
            ? 'ระบุวันที่ตั้งแต่วันนี้เป็นต้นไป'
            : draft.time == null || !_isValidTime(draft)
            ? 'ระบุเวลาให้บริการระหว่าง 09:00–20:00 น. และจบไม่เกิน 21:00 น.'
            : draft.customerName == null
            ? 'แจ้งชื่อผู้จอง'
            : 'ระบบมีข้อมูลครบแล้วและจะแสดงสรุปให้ลูกค้ายืนยัน';

    return '''
ขณะนี้คุณกำลังช่วยลูกค้าคุยเพื่อเก็บข้อมูลสำหรับการจองจำลอง
ข้อมูลที่แอปบันทึกและตรวจสอบได้แล้ว:
- บริการ: ${service?.name ?? 'ยังไม่ได้ระบุ'}
- วันที่: ${date == null ? 'ยังไม่ได้ระบุ' : _formatThaiDate(date)}
- เวลา: ${draft.time ?? 'ยังไม่ได้ระบุ'}
- ชื่อผู้จอง: ${draft.customerName ?? 'ยังไม่ได้ระบุ'}
ขั้นตอนถัดไปที่แอปต้องการ: $nextStep

ตอบข้อความล่าสุดของลูกค้าให้เป็นธรรมชาติ ไม่ใช้ประโยคสำเร็จรูปหรือทวนข้อมูลที่ลูกค้าให้แล้ว
ถ้าลูกค้าถามหรือขอคำแนะนำ ให้ตอบก่อน แล้วค่อยถามข้อมูลเฉพาะขั้นตอนถัดไป
อ้างอิงบริการได้จากรายการ Mock Data ในคำสั่งระบบเท่านั้น และอย่าคิดราคา/ระยะเวลา/บริการเพิ่มเติมเอง
ห้ามอ้างว่ามีคิวว่าง ห้ามบอกว่าจองสำเร็จ และไม่ต้องสรุปการจอง เพราะแอปจะจัดการสรุปและยืนยันเอง
''';
  }

  Future<void> _advanceBookingConversation(String text) async {
    setState(() => _isTyping = true);
    _scrollToBottom();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final startingDraft =
        _bookingDraft.isActive
            ? _bookingDraft
            : const BookingDraft(isActive: true);
    final updatedDraft = _readBookingDetails(startingDraft, text);

    if (startingDraft.awaitingConfirmation && _isCancellation(text)) {
      setState(() {
        _bookingDraft = const BookingDraft();
        _messages.add(
          const ChatMessage(
            text:
                'ยกเลิกการจำลองการจองแล้ว หากต้องการเริ่มใหม่พิมพ์ “จองคิว” ได้เลยค่ะ',
            role: ChatMessageRole.assistant,
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    if (startingDraft.awaitingConfirmation && _isConfirmation(text)) {
      if (updatedDraft.isComplete &&
          _isValidDate(updatedDraft.date!) &&
          _isValidTime(updatedDraft)) {
        _confirmDemoBooking(updatedDraft);
      } else {
        final response = _bookingProgressMessage(updatedDraft);
        setState(() {
          _bookingDraft = updatedDraft.copyWith(awaitingConfirmation: false);
          _messages.add(
            ChatMessage(text: response, role: ChatMessageRole.assistant),
          );
          _isTyping = false;
        });
      }
      _scrollToBottom();
      return;
    }

    final readyForConfirmation = _isReadyForConfirmation(updatedDraft);
    final savedDraft = updatedDraft.copyWith(
      awaitingConfirmation: readyForConfirmation,
    );
    setState(() => _bookingDraft = savedDraft);

    if (readyForConfirmation) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: _bookingProgressMessage(savedDraft),
            role: ChatMessageRole.assistant,
          ),
        );
        _isTyping = false;
      });
      _scrollToBottom();
      return;
    }

    await _requestGeminiReply(
      bookingDraft: savedDraft,
      fallbackText: _bookingProgressMessage(savedDraft),
    );
  }

  Future<void> _retryGeminiReply() => _requestGeminiReply(
    bookingDraft: _retryBookingDraft,
    fallbackText:
        _retryBookingDraft == null
            ? null
            : _bookingProgressMessage(_retryBookingDraft!),
  );

  BookingDraft _readBookingDetails(BookingDraft draft, String text) {
    final service = MassageMockData.findServiceMentionedIn(text);
    final date = _parseDate(text);
    final time = _parseTime(text);
    final explicitName = _parseCustomerName(text);
    final isNameOnlyAnswer =
        draft.service != null &&
        draft.date != null &&
        draft.time != null &&
        draft.customerName == null &&
        service == null &&
        date == null &&
        time == null;
    final name =
        explicitName ?? (isNameOnlyAnswer ? _parseNameOnlyAnswer(text) : null);

    return draft.copyWith(
      service: service,
      date: date,
      time: time,
      customerName: name,
      awaitingConfirmation: false,
    );
  }

  String _bookingProgressMessage(BookingDraft draft) {
    final service = draft.service;
    if (service == null) {
      if (MassageMockData.mentionsServiceType(_messages.last.text)) {
        final choices = MassageMockData.services
            .where(
              (item) => item.name.startsWith(
                _messages.last.text.contains('นวดไทย')
                    ? 'นวดไทย'
                    : _messages.last.text.contains('นวดน้ำมัน')
                    ? 'นวดน้ำมัน'
                    : _messages.last.text.contains('นวดเท้า')
                    ? 'นวดเท้า'
                    : 'อโรม่า',
              ),
            )
            .map((item) => '${item.name} (${item.priceBaht} บาท)')
            .join(' หรือ ');
        return 'มีบริการ $choices ค่ะ ต้องการเลือกบริการไหนคะ?';
      }
      final catalog = MassageMockData.services
          .map((item) => '${item.name} — ${item.priceBaht} บาท')
          .join('\n');
      return 'ขั้นแรกเลือกบริการที่ต้องการได้เลยค่ะ\n$catalog';
    }

    final date = draft.date;
    if (date == null || !_isValidDate(date)) {
      return date != null
          ? 'วันที่เลือกผ่านไปแล้ว กรุณาระบุวันที่ตั้งแต่วันนี้เป็นต้นไป เช่น “พรุ่งนี้” หรือ “12/11/2026” ค่ะ'
          : 'รับทราบค่ะ เลือกวันที่ต้องการได้เลย เช่น “พรุ่งนี้” หรือ “12/11/2026” ค่ะ';
    }

    if (draft.time == null || !_isValidTime(draft)) {
      return draft.time != null
          ? 'เวลานี้อยู่นอกช่วงให้บริการตัวอย่าง กรุณาเลือกเวลา 09:00–20:00 น. และเวลาเสร็จต้องไม่เกิน 21:00 น. ค่ะ'
          : 'ต้องการเข้ารับบริการเวลาใดคะ? เลือกได้ระหว่าง 09:00–20:00 น. โดยบริการต้องเสร็จไม่เกิน 21:00 น. ค่ะ';
    }

    if (draft.customerName == null) {
      return 'ขอชื่อผู้จองด้วยค่ะ (พิมพ์ชื่อได้เลย)';
    }

    return 'สรุปรายละเอียดการจองจำลอง\n'
        'บริการ: ${service.name}\n'
        'วันที่: ${_formatThaiDate(date)}\n'
        'เวลา: ${draft.time} น.\n'
        'ชื่อผู้จอง: ${draft.customerName}\n'
        'ระยะเวลา: ${service.durationMinutes} นาที\n'
        'ราคา: ${service.priceBaht} บาท\n\n'
        'การจองนี้เป็นการจำลองเท่านั้น ยังไม่ได้จองคิวจริงกับร้าน '
        'หากข้อมูลถูกต้อง พิมพ์ “ยืนยัน” เพื่อดำเนินการค่ะ';
  }

  void _confirmDemoBooking(BookingDraft draft) {
    final booking = DemoBooking(
      id: 'DEMO-${(_nextDemoBookingNumber++).toString().padLeft(4, '0')}',
      customerName: draft.customerName!,
      service: draft.service!,
      date: draft.date!,
      time: draft.time!,
    );
    DemoBookingStore.add(booking);

    setState(() {
      _bookingDraft = const BookingDraft();
      _messages.add(
        ChatMessage(
          text: 'ยืนยันการจองจำลองเรียบร้อยแล้วค่ะ',
          role: ChatMessageRole.assistant,
          bookingConfirmation: booking,
        ),
      );
      _isTyping = false;
    });
  }

  DateTime? _parseDate(String text) {
    final relativeText = text.toLowerCase();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (relativeText.contains('มะรืน')) {
      return today.add(const Duration(days: 2));
    }
    if (relativeText.contains('พรุ่งนี้')) {
      return today.add(const Duration(days: 1));
    }
    if (relativeText.contains('วันนี้')) return today;

    final isoDate = RegExp(r'\b(\d{4})-(\d{1,2})-(\d{1,2})\b').firstMatch(text);
    if (isoDate != null) {
      return _validDate(
        int.parse(isoDate.group(1)!),
        int.parse(isoDate.group(2)!),
        int.parse(isoDate.group(3)!),
      );
    }

    final numericDate = RegExp(
      r'(?<!\d)(\d{1,2})[/-](\d{1,2})(?:[/-](\d{2,4}))?(?!\d)',
    ).firstMatch(text);
    if (numericDate != null) {
      var year =
          numericDate.group(3) == null
              ? now.year
              : int.parse(numericDate.group(3)!);
      if (year >= 2400) year -= 543;
      if (year < 100) year += 2000;
      return _validDate(
        year,
        int.parse(numericDate.group(2)!),
        int.parse(numericDate.group(1)!),
      );
    }

    const monthNames = {
      'มกราคม': 1,
      'ม.ค.': 1,
      'กุมภาพันธ์': 2,
      'ก.พ.': 2,
      'มีนาคม': 3,
      'มี.ค.': 3,
      'เมษายน': 4,
      'เม.ย.': 4,
      'พฤษภาคม': 5,
      'พ.ค.': 5,
      'มิถุนายน': 6,
      'มิ.ย.': 6,
      'กรกฎาคม': 7,
      'ก.ค.': 7,
      'สิงหาคม': 8,
      'ส.ค.': 8,
      'กันยายน': 9,
      'ก.ย.': 9,
      'ตุลาคม': 10,
      'ต.ค.': 10,
      'พฤศจิกายน': 11,
      'พ.ย.': 11,
      'ธันวาคม': 12,
      'ธ.ค.': 12,
    };
    for (final entry in monthNames.entries) {
      final match = RegExp(
        '(\\d{1,2})\\s*${RegExp.escape(entry.key)}\\s*(\\d{2,4})?',
      ).firstMatch(text);
      if (match == null) continue;

      var year = match.group(2) == null ? now.year : int.parse(match.group(2)!);
      if (year >= 2400) year -= 543;
      if (year < 100) year += 2000;
      return _validDate(year, entry.value, int.parse(match.group(1)!));
    }
    return null;
  }

  DateTime? _validDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  String? _parseTime(String text) {
    final numericTime = RegExp(
      r'(?<!\d)(\d{1,2})[:.](\d{2})(?!\d)',
    ).firstMatch(text);
    if (numericTime != null) {
      return '${numericTime.group(1)!.padLeft(2, '0')}:${numericTime.group(2)}';
    }

    final evening = RegExp(r'(\d{1,2})\s*ทุ่ม').firstMatch(text);
    if (evening != null) {
      final hour = int.parse(evening.group(1)!) + 18;
      return '${hour.toString().padLeft(2, '0')}:00';
    }

    final afternoon = RegExp(r'บ่าย\s*(\d{1,2})').firstMatch(text);
    if (afternoon != null) {
      final hour = int.parse(afternoon.group(1)!);
      return '${(hour + 12).toString().padLeft(2, '0')}:00';
    }

    final thaiHour = RegExp(
      r'(?:เวลา|ตอน)\s*(\d{1,2})(?:\s*โมง)?|(\d{1,2})\s*โมง',
    ).firstMatch(text);
    if (thaiHour == null) return null;

    var hour = int.parse(thaiHour.group(1) ?? thaiHour.group(2)!);
    final contextEnd =
        thaiHour.end + 4 < text.length ? thaiHour.end + 4 : text.length;
    final context = text.substring(thaiHour.start, contextEnd);
    if (context.contains('บ่าย') && hour < 12) hour += 12;
    if (context.contains('เย็น') && hour < 12) hour += 12;
    return '${hour.toString().padLeft(2, '0')}:00';
  }

  String? _parseCustomerName(String text) {
    final match = RegExp(
      r'(?:ชื่อ(?:ผู้จอง)?(?:คือ|ว่า)?|(?:ผม|ฉัน|หนู|ดิฉัน)ชื่อ|เรียกฉันว่า)\s*([^\n,。.]+)',
    ).firstMatch(text);
    if (match == null) return null;
    return _cleanName(match.group(1)!);
  }

  String? _parseNameOnlyAnswer(String text) {
    final candidate = _cleanName(text);
    if (candidate.length < 2 ||
        candidate.length > 50 ||
        RegExp(r'\d').hasMatch(candidate) ||
        RegExp(
          r'^(ใช่|ตกลง|ยืนยัน|โอเค|ไม่|ยกเลิก|ขอ|อยาก|ถาม|เปลี่ยน)$',
        ).hasMatch(candidate) ||
        RegExp(
          r'จอง|ยืนยัน|ยกเลิก|บริการ|ราคา|เวลา|พรุ่งนี้|วันนี้|ถาม',
        ).hasMatch(candidate)) {
      return null;
    }
    return candidate;
  }

  String _cleanName(String name) =>
      name
          .trim()
          .replaceFirst(RegExp(r'(ครับ|ค่ะ|คะ|นะ)$'), '')
          .replaceFirst(RegExp(r'[.!?。၊,]+$'), '')
          .trim();

  bool _isValidDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return !date.isBefore(today);
  }

  bool _isValidTime(BookingDraft draft) {
    final time = draft.time;
    final service = draft.service;
    if (time == null || service == null) return false;
    final parts = time.split(':');
    if (parts.length != 2) return false;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return false;
    final start = hour * 60 + minute;
    final openingTime = 9 * 60;
    final closingTime = 21 * 60;
    return start >= openingTime &&
        start < closingTime &&
        minute < 60 &&
        start + service.durationMinutes <= closingTime;
  }

  bool _isReadyForConfirmation(BookingDraft draft) =>
      draft.isComplete && _isValidDate(draft.date!) && _isValidTime(draft);

  bool _isConfirmation(String text) => RegExp(
    r'^(ยืนยัน|ตกลง|ใช่|โอเค|confirm|yes)(?:$|\s|ค่ะ|ครับ|นะ)',
    caseSensitive: false,
  ).hasMatch(text.trim());

  bool _isCancellation(String text) => RegExp(
    r'^(ยกเลิก|ไม่จอง|ไม่ยืนยัน|ไม่เอา|cancel|no)(?:$|\s|ค่ะ|ครับ|นะ)',
    caseSensitive: false,
  ).hasMatch(text.trim());

  String _formatThaiDate(DateTime date) =>
      '${date.day} ${_months[date.month - 1]} ${date.year + 543}';

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  void _showNavigation(int index) {
    final route = _navigationRoutes[index];
    if (route == '/ai-chat') return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _SpaColors.cream,
      appBar: AppBar(
        backgroundColor: _SpaColors.cream,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 4,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _SpaColors.lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.spa_rounded,
                color: _SpaColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 11),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MASSAGE AI',
                  style: _prompt(
                    16,
                    weight: FontWeight.w600,
                    color: _SpaColors.darkGreen,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF56A76A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Online · ผู้ช่วยดูแลคุณ',
                      style: _prompt(11, color: _SpaColors.muted),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(child: _buildConversation()),
            _buildQuickSuggestions(),
            _buildComposer(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 2,
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: _SpaColors.lightGreen,
        onDestinationSelected: _showNavigation,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'หน้าหลัก',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'จองคิว',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'AI Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'การจอง',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }

  Widget _buildConversation() {
    final extraItems =
        _messages.isEmpty
            ? 1
            : (_isTyping ? 1 : 0) + (_requestError == null ? 0 : 1);
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _messages.length + extraItems,
      itemBuilder: (context, index) {
        if (_messages.isEmpty) return const _WelcomeCard();
        if (index < _messages.length) {
          return _ChatMessageBubble(message: _messages[index]);
        }

        var statusIndex = index - _messages.length;
        if (_isTyping) {
          if (statusIndex == 0) return const _TypingIndicator();
          statusIndex--;
        }
        if (_requestError != null && statusIndex == 0) {
          return _RequestErrorCard(
            message: _requestError!,
            onRetry: _retryGeminiReply,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildQuickSuggestions() {
    final suggestions =
        !_bookingDraft.isActive
            ? const [
              'แนะนำบริการนวด',
              'ขอดูบริการและราคา',
              'เริ่มจองนวดไทย 60 นาที',
            ]
            : _bookingDraft.awaitingConfirmation
            ? const ['ยืนยัน', 'ยกเลิก']
            : _bookingDraft.service == null
            ? MassageMockData.services.map((service) => service.name).toList()
            : _bookingDraft.date == null
            ? const ['วันนี้', 'พรุ่งนี้', 'มะรืนนี้']
            : _bookingDraft.time == null
            ? const ['10:00', '14:00', '18:00']
            : _bookingDraft.customerName == null
            ? const ['ชื่อ สมชาย']
            : const ['ยืนยัน'];
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final suggestion = suggestions[index];
          return ActionChip(
            label: Text(suggestion, style: _prompt(12)),
            backgroundColor: Colors.white,
            side: const BorderSide(color: _SpaColors.border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: _isTyping ? null : () => _sendMessage(suggestion),
          );
        },
      ),
    );
  }

  Widget _buildComposer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _SpaColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              decoration: InputDecoration(
                hintText: 'พิมพ์ข้อความของคุณ...',
                hintStyle: _prompt(13, color: _SpaColors.muted),
                filled: true,
                fillColor: _SpaColors.cream,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          SizedBox(
            width: 46,
            height: 46,
            child: FilledButton(
              onPressed: _isTyping ? null : () => _sendMessage(),
              style: FilledButton.styleFrom(
                backgroundColor: _SpaColors.primaryGreen,
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              child: const Icon(Icons.arrow_upward_rounded, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 28, bottom: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _SpaColors.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A294C3A),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _SpaColors.lightGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: _SpaColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 17),
          Text(
            'สวัสดีค่ะ ยินดีต้อนรับ 👋',
            style: _prompt(
              19,
              weight: FontWeight.w600,
              color: _SpaColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'อยากผ่อนคลายแบบไหนคะ? ฉันช่วยแนะนำบริการ '
            'ตอบคำถาม และทดลองทำรายการจองให้ได้ค่ะ',
            style: _prompt(13, color: _SpaColors.muted, height: 1.65),
          ),
          const SizedBox(height: 14),
          const Divider(color: _SpaColors.border),
          const SizedBox(height: 8),
          Text(
            'บริการและราคาตัวอย่าง',
            style: _prompt(
              13,
              weight: FontWeight.w600,
              color: _SpaColors.darkGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...MassageMockData.services.map(
            (service) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(
                    Icons.circle,
                    size: 6,
                    color: _SpaColors.primaryGreen,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '${service.name} · ${service.priceBaht} บาท',
                      style: _prompt(12, color: _SpaColors.muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'หมายเหตุ: การจองผ่านแชตเป็น Demo เท่านั้น '
            'ไม่ใช่การจองคิวจริงกับร้าน',
            style: _prompt(11, color: _SpaColors.muted, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isFromUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.8,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? _SpaColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 5),
                  bottomRight: Radius.circular(isUser ? 5 : 18),
                ),
                border: isUser ? null : Border.all(color: _SpaColors.border),
              ),
              child: Text(
                message.text,
                style: _prompt(
                  13,
                  color: isUser ? Colors.white : _SpaColors.darkGreen,
                  height: 1.55,
                ),
              ),
            ),
          ),
          if (message.bookingConfirmation case final booking?) ...[
            const SizedBox(height: 8),
            _BookingConfirmationCard(booking: booking),
          ],
        ],
      ),
    );
  }
}

class _BookingConfirmationCard extends StatelessWidget {
  const _BookingConfirmationCard({required this.booking});

  final DemoBooking booking;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _SpaColors.lightGreen, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A294C3A),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: _SpaColors.primaryGreen,
                size: 23,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Demo Booking Confirmed',
                  style: _prompt(
                    14,
                    weight: FontWeight.w600,
                    color: _SpaColors.darkGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(booking.id, style: _prompt(11, color: _SpaColors.muted)),
          const SizedBox(height: 14),
          _BookingDetailRow(label: 'ชื่อผู้จอง', value: booking.customerName),
          _BookingDetailRow(label: 'บริการ', value: booking.service.name),
          _BookingDetailRow(
            label: 'วันที่',
            value:
                '${booking.date.day} ${_AiChatUiState._months[booking.date.month - 1]} ${booking.date.year + 543}',
          ),
          _BookingDetailRow(label: 'เวลา', value: '${booking.time} น.'),
          _BookingDetailRow(
            label: 'ระยะเวลา',
            value: '${booking.service.durationMinutes} นาที',
          ),
          _BookingDetailRow(
            label: 'ราคา',
            value: '${booking.service.priceBaht} บาท',
            emphasize: true,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'นี่คือการจองจำลองในแอปเท่านั้น '
              'ไม่ได้จองคิวจริงหรือส่งข้อมูลไปยังร้าน',
              style: _prompt(11, color: const Color(0xFF755D2D), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookingDetailRow extends StatelessWidget {
  const _BookingDetailRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final valueColor =
        emphasize ? _SpaColors.primaryGreen : _SpaColors.darkGreen;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 82,
            child: Text(label, style: _prompt(12, color: _SpaColors.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: _prompt(
                12,
                weight: emphasize ? FontWeight.w600 : FontWeight.w400,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _SpaColors.border),
        ),
        child: Text(
          'กำลังพิมพ์...',
          style: _prompt(12, color: _SpaColors.muted),
        ),
      ),
    );
  }
}

class _RequestErrorCard extends StatelessWidget {
  const _RequestErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2EF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0CEC5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: _prompt(12, color: const Color(0xFF8A3D2D), height: 1.5),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              'ลองอีกครั้ง',
              style: _prompt(12, weight: FontWeight.w600),
            ),
            style: TextButton.styleFrom(
              foregroundColor: _SpaColors.primaryGreen,
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaColors {
  static const primaryGreen = Color(0xFF426B55);
  static const darkGreen = Color(0xFF294C3A);
  static const cream = Color(0xFFF7F6F0);
  static const lightGreen = Color(0xFFE7EFE8);
  static const muted = Color(0xFF7C8981);
  static const border = Color(0xFFE6E9E3);
}

TextStyle _prompt(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = _SpaColors.darkGreen,
  double? height,
}) {
  return GoogleFonts.prompt(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}
