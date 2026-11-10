import 'package:flutter/material.dart';
import 'package:flutter_application_massage/view/model/booking_draft_model.dart';

// ====================== Model ======================

enum BookingStatus {
  pending('รอดำเนินการ', Colors.orange),
  confirmed('ยืนยันแล้ว', Colors.green),
  inProgress('กำลังให้บริการ', Colors.blue),
  completed('เสร็จสิ้น', Colors.teal),
  cancelled('ยกเลิกแล้ว', Colors.grey),
  rejected('ไม่รับการจอง', Colors.red);

  final String label;
  final MaterialColor color;
  const BookingStatus(this.label, this.color);
}

class BookingModel {
  final String id; // เช่น BK001
  final String serviceName;
  final String? imageUrl;
  final DateTime date;
  final int startHour;
  final int startMinute;
  final int durationMinutes;
  final String therapist;
  final String? customerName;
  final double price;
  final BookingStatus status;
  final DateTime createdAt;
  final String? cancelReason;

  const BookingModel({
    required this.id,
    required this.serviceName,
    this.imageUrl,
    required this.date,
    required this.startHour,
    this.startMinute = 0,
    required this.durationMinutes,
    required this.therapist,
    this.customerName,
    required this.price,
    required this.status,
    required this.createdAt,
    this.cancelReason,
  });

  DateTime get startDateTime =>
      DateTime(date.year, date.month, date.day, startHour, startMinute);

  DateTime get endDateTime =>
      startDateTime.add(Duration(minutes: durationMinutes));

  String get timeRange =>
      '${_fmtTime(startDateTime)} – ${_fmtTime(endDateTime)} น.';

  BookingModel copyWith({BookingStatus? status, String? cancelReason}) =>
      BookingModel(
        id: id,
        serviceName: serviceName,
        imageUrl: imageUrl,
        date: date,
        startHour: startHour,
        startMinute: startMinute,
        durationMinutes: durationMinutes,
        therapist: therapist,
        customerName: customerName,
        price: price,
        status: status ?? this.status,
        createdAt: createdAt,
        cancelReason: cancelReason ?? this.cancelReason,
      );
}

// ====================== ตัวช่วย ======================

const _thaiMonths = [
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

String _fmtDate(DateTime d) =>
    '${d.day} ${_thaiMonths[d.month - 1]} ${d.year + 543}';

String _fmtTime(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String _fmtDateTime(DateTime d) => '${_fmtDate(d)} ${_fmtTime(d)} น.';

String _money(double v) => v
    .toStringAsFixed(0)
    .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');

String _duration(int minutes) {
  final h = minutes ~/ 60;
  final m = minutes % 60;
  if (h == 0) return '$m นาที';
  if (m == 0) return '$h ชั่วโมง';
  return '$h ชั่วโมง $m นาที';
}

// ====================== หน้าหลัก ======================

class MyBookingUi extends StatefulWidget {
  const MyBookingUi({super.key});

  @override
  State<MyBookingUi> createState() => _MyBookingUiState();
}

class _MyBookingUiState extends State<MyBookingUi> {
  // null = ทั้งหมด
  BookingStatus? _filter;

  /// เวลาที่ต้องยกเลิกล่วงหน้าก่อนถึงคิว (นโยบายร้าน)
  static const int _cancelBeforeHours = 2;

  static const _shopPhone = '02-123-4567'; // TODO: ใส่เบอร์ร้านจริง

  // TODO: เปลี่ยนเป็นดึงข้อมูลจาก Supabase (ตาราง bookings ของลูกค้าที่ล็อกอิน)
  late final List<BookingModel> _bookings = [
    ..._sampleData(),
    ...DemoBookingStore.bookings.map(_fromDemoBooking),
  ];

  static BookingModel _fromDemoBooking(DemoBooking booking) {
    final timeParts = booking.time.split(':');
    return BookingModel(
      id: booking.id,
      serviceName: booking.service.name,
      date: booking.date,
      startHour: int.parse(timeParts[0]),
      startMinute: int.parse(timeParts[1]),
      durationMinutes: booking.service.durationMinutes,
      therapist: 'ยังไม่ระบุ (Demo)',
      customerName: booking.customerName,
      price: booking.service.priceBaht.toDouble(),
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
  }

  static List<BookingModel> _sampleData() {
    final now = DateTime.now();
    DateTime day(int offset) =>
        DateTime(now.year, now.month, now.day).add(Duration(days: offset));

    return [
      BookingModel(
        id: 'BK008',
        serviceName: 'นวดอโรม่า',
        date: day(1),
        startHour: 16,
        durationMinutes: 90,
        therapist: 'คุณ B',
        price: 600,
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      BookingModel(
        id: 'BK007',
        serviceName: 'นวดแผนไทย',
        date: day(3),
        startHour: 14,
        durationMinutes: 60,
        therapist: 'คุณ A',
        price: 300,
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      BookingModel(
        id: 'BK006',
        serviceName: 'นวดเท้า',
        date: day(5),
        startHour: 10,
        durationMinutes: 60,
        therapist: 'คุณ C',
        price: 250,
        status: BookingStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      BookingModel(
        id: 'BK005',
        serviceName: 'นวดน้ำมัน',
        date: day(-3),
        startHour: 18,
        durationMinutes: 90,
        therapist: 'คุณ D',
        price: 600,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 6)),
      ),
      BookingModel(
        id: 'BK004',
        serviceName: 'นวดแผนไทย',
        date: day(-8),
        startHour: 13,
        durationMinutes: 120,
        therapist: 'คุณ A',
        price: 550,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      BookingModel(
        id: 'BK003',
        serviceName: 'นวดเท้า',
        date: day(-10),
        startHour: 11,
        durationMinutes: 60,
        therapist: 'คุณ C',
        price: 250,
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      BookingModel(
        id: 'BK002',
        serviceName: 'นวดอโรม่า',
        date: day(-5),
        startHour: 15,
        durationMinutes: 90,
        therapist: 'คุณ B',
        price: 600,
        status: BookingStatus.cancelled,
        createdAt: now.subtract(const Duration(days: 9)),
        cancelReason: 'ติดธุระกะทันหัน',
      ),
    ];
  }

  // ---------- ข้อมูลที่กรองแล้ว ----------

  List<BookingModel> get _filtered {
    final list =
        _bookings.where((b) => _filter == null || b.status == _filter).toList();
    // ใหม่ไปเก่า
    list.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));
    return list;
  }

  int _count(BookingStatus s) => _bookings.where((b) => b.status == s).length;

  // ---------- Actions ----------

  bool _canCancel(BookingModel b) {
    if (b.status != BookingStatus.pending &&
        b.status != BookingStatus.confirmed) {
      return false;
    }
    return true;
  }

  /// ตรวจนโยบายการยกเลิก: ต้องยกเลิกก่อนถึงคิวอย่างน้อย N ชั่วโมง
  bool _withinPolicy(BookingModel b) {
    final deadline = b.startDateTime.subtract(
      const Duration(hours: _cancelBeforeHours),
    );
    return DateTime.now().isBefore(deadline);
  }

  Future<void> _cancelBooking(BookingModel b) async {
    // ตรวจนโยบายก่อนเปลี่ยนสถานะ
    if (!_withinPolicy(b)) {
      await showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              icon: const Icon(
                Icons.info_outline,
                color: Colors.orange,
                size: 48,
              ),
              title: const Text('ไม่สามารถยกเลิกได้'),
              content: Text(
                'ต้องยกเลิกล่วงหน้าอย่างน้อย $_cancelBeforeHours ชั่วโมงก่อนเวลานัด\n'
                'กรุณาติดต่อร้านโดยตรงที่ $_shopPhone',
                textAlign: TextAlign.center,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('ตกลง'),
                ),
              ],
            ),
      );
      return;
    }

    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelDialog(),
    );
    if (reason == null) return;

    // TODO: update status = 'cancelled' และบันทึก cancel_reason ใน Supabase
    // ห้ามลบแถวทิ้ง ให้เปลี่ยนสถานะเท่านั้น
    setState(() {
      final i = _bookings.indexWhere((e) => e.id == b.id);
      _bookings[i] = b.copyWith(
        status: BookingStatus.cancelled,
        cancelReason: reason,
      );
    });

    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('ยกเลิกการจอง #${b.id} แล้ว')));
  }

  void _contactShop(BookingModel b) {
    // TODO: ใช้แพ็กเกจ url_launcher โทรออกหรือเปิด LINE ของร้าน
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: const Icon(Icons.support_agent, size: 48),
            title: const Text('ติดต่อร้าน'),
            content: Text(
              'สอบถามเรื่องการจอง #${b.id}\nโทร $_shopPhone',
              textAlign: TextAlign.center,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('ปิด'),
              ),
            ],
          ),
    );
  }

  void _rebook(BookingModel b) {
    // ไปหน้าจอง พร้อมส่งชื่อบริการเดิมไปด้วย
    // (BookingUi ต้องอ่าน ModalRoute.of(context)!.settings.arguments ถึงจะใช้ค่านี้)
    Navigator.pushNamed(context, '/booking', arguments: b.serviceName);
  }

  void _showDetail(BookingModel b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final primary = Theme.of(ctx).colorScheme.primary;

        Widget row(IconData icon, String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: primary),
              const SizedBox(width: 12),
              SizedBox(
                width: 96,
                child: Text(
                  label,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Booking #${b.id}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  _StatusBadge(status: b.status),
                ],
              ),
              const SizedBox(height: 8),
              row(Icons.confirmation_number_outlined, 'Booking ID', b.id),
              row(Icons.spa, 'บริการ', b.serviceName),
              row(Icons.calendar_month, 'วันที่', _fmtDate(b.date)),
              row(Icons.schedule, 'เวลา', b.timeRange),
              row(Icons.person, 'พนักงาน', b.therapist),
              row(Icons.timer, 'ระยะเวลา', _duration(b.durationMinutes)),
              row(Icons.payments, 'ราคา', '${_money(b.price)} บาท'),
              row(Icons.flag_outlined, 'สถานะ', b.status.label),
              row(Icons.history, 'วันที่สร้าง', _fmtDateTime(b.createdAt)),
              if (b.cancelReason != null)
                row(Icons.comment_outlined, 'เหตุผลยกเลิก', b.cancelReason!),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _contactShop(b);
                      },
                      icon: const Icon(Icons.support_agent),
                      label: const Text('ติดต่อร้าน'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _rebook(b);
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('จองอีกครั้ง'),
                    ),
                  ),
                ],
              ),
              if (_canCancel(b)) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _cancelBooking(b);
                    },
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('ยกเลิกการจอง'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ====================== UI ======================

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('การจองของฉัน'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'แจ้งเตือน',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: เปิดหน้าแจ้งเตือน
            },
          ),
        ],
      ),
      body:
          _bookings.isEmpty
              ? _buildEmptyState()
              : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildStats(),
                  const SizedBox(height: 20),
                  _buildFilterTabs(),
                  const SizedBox(height: 16),
                  if (items.isEmpty)
                    _buildNoResult()
                  else
                    ...items.map(_buildBookingCard),
                ],
              ),
    );
  }

  // ---------- ส่วนที่ 1: Header ----------
  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'การจองของฉัน',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: 4),
        Text(
          'ตรวจสอบและจัดการรายการจองบริการของคุณ',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ---------- ส่วนที่ 2: สรุปสถานะ ----------
  Widget _buildStats() {
    final pending = _count(BookingStatus.pending);
    final confirmed =
        _count(BookingStatus.confirmed) + _count(BookingStatus.inProgress);
    final completed = _count(BookingStatus.completed);

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _StatCard(
          icon: Icons.receipt_long,
          color: Colors.indigo,
          label: 'ทั้งหมด',
          value: '${_bookings.length}',
        ),
        _StatCard(
          icon: Icons.hourglass_top,
          color: Colors.orange,
          label: 'รอดำเนินการ',
          value: '$pending',
        ),
        _StatCard(
          icon: Icons.check_circle,
          color: Colors.green,
          label: 'ยืนยันแล้ว',
          value: '$confirmed',
        ),
        _StatCard(
          icon: Icons.verified,
          color: Colors.teal,
          label: 'เสร็จสิ้น',
          value: '$completed',
        ),
      ],
    );
  }

  // ---------- ส่วนที่ 3: ตัวกรอง ----------
  Widget _buildFilterTabs() {
    final tabs = <(String, BookingStatus?)>[
      ('ทั้งหมด', null),
      ('รอดำเนินการ', BookingStatus.pending),
      ('ยืนยันแล้ว', BookingStatus.confirmed),
      ('เสร็จสิ้น', BookingStatus.completed),
      ('ยกเลิกแล้ว', BookingStatus.cancelled),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'เลือกสถานะการจอง',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                tabs.map((t) {
                  final count = t.$2 == null ? _bookings.length : _count(t.$2!);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text('${t.$1} ($count)'),
                      selected: _filter == t.$2,
                      onSelected: (_) => setState(() => _filter = t.$2),
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  // ---------- ส่วนที่ 4: การ์ดการจอง ----------
  Widget _buildBookingCard(BookingModel b) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Booking #${b.id}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                _StatusBadge(status: b.status),
              ],
            ),
            if (b.id.startsWith('DEMO-'))
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Chip(
                  label: Text('DEMO · ไม่ใช่คิวจริง'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: scheme.primaryContainer,
                    child:
                        b.imageUrl != null
                            ? Image.network(
                              b.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.spa,
                                    color: scheme.primary,
                                    size: 30,
                                  ),
                            )
                            : Icon(Icons.spa, color: scheme.primary, size: 30),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'ระยะเวลา ${_duration(b.durationMinutes)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_money(b.price)} บาท',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoLine(icon: Icons.calendar_month, text: _fmtDate(b.date)),
            const SizedBox(height: 6),
            _InfoLine(icon: Icons.schedule, text: b.timeRange),
            if (b.customerName != null) ...[
              const SizedBox(height: 6),
              _InfoLine(
                icon: Icons.person_outline,
                text: 'ผู้จอง: ${b.customerName}',
              ),
            ],
            const SizedBox(height: 6),
            _InfoLine(icon: Icons.person, text: 'พนักงาน: ${b.therapist}'),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showDetail(b),
                    child: const Text('ดูรายละเอียด'),
                  ),
                ),
                if (_canCancel(b)) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                      ),
                      onPressed: () => _cancelBooking(b),
                      child: const Text('ยกเลิกการจอง'),
                    ),
                  ),
                ] else if (b.status == BookingStatus.completed ||
                    b.status == BookingStatus.cancelled ||
                    b.status == BookingStatus.rejected) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _rebook(b),
                      child: const Text('จองอีกครั้ง'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResult() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        Icon(Icons.inbox_outlined, size: 56, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(
          'ไม่มีรายการในสถานะนี้',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      ],
    ),
  );

  // ---------- ส่วนที่ 6: Empty State ----------
  Widget _buildEmptyState() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.event_busy, size: 56, color: scheme.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'ยังไม่มีรายการจอง',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณยังไม่มีรายการจองบริการ\nเริ่มต้นผ่อนคลายด้วยการจองบริการที่คุณชื่นชอบได้เลย',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/booking'),
              icon: const Icon(Icons.add),
              label: const Text('จองบริการเลย'),
            ),
          ],
        ),
      ),
    );
  }
}

// ====================== Widgets ย่อย ======================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final MaterialColor color;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color.shade700, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: color.shade800,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  'รายการ',
                  style: TextStyle(fontSize: 12, color: color.shade700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final BookingStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final c = status.color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: c.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}

// ====================== Dialog ยืนยันยกเลิก ======================

class _CancelDialog extends StatefulWidget {
  const _CancelDialog();

  @override
  State<_CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<_CancelDialog> {
  static const _reasons = [
    'ติดธุระกะทันหัน',
    'ไม่สะดวกในวันและเวลานี้',
    'จองผิดบริการหรือเวลา',
    'อื่น ๆ',
  ];

  String? _selected;
  final _otherCtrl = TextEditingController();

  @override
  void dispose() {
    _otherCtrl.dispose();
    super.dispose();
  }

  bool get _valid =>
      _selected != null &&
      (_selected != 'อื่น ๆ' || _otherCtrl.text.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 48),
      title: const Text('ยกเลิกการจอง'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('กรุณาเลือกเหตุผลที่ต้องการยกเลิก'),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v),
              child: Column(
                children:
                    _reasons
                        .map(
                          (r) => RadioListTile<String>(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            title: Text(r),
                            value: r,
                          ),
                        )
                        .toList(),
              ),
            ),
            if (_selected == 'อื่น ๆ')
              TextField(
                controller: _otherCtrl,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'ระบุเหตุผล',
                  border: OutlineInputBorder(),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('ไม่ยกเลิก'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          onPressed:
              !_valid
                  ? null
                  : () => Navigator.pop(
                    context,
                    _selected == 'อื่น ๆ' ? _otherCtrl.text.trim() : _selected,
                  ),
          child: const Text('ยืนยันยกเลิก'),
        ),
      ],
    );
  }
}
