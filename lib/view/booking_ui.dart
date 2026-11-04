import 'package:flutter/material.dart';

class BookingUi extends StatefulWidget {
  const BookingUi({super.key});

  @override
  State<BookingUi> createState() => _BookingUiState();
}

class _BookingUiState extends State<BookingUi> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTime;
  int _guests = 1;
  int _hours = 1;

  static const int _closingHour = 21; // เวลาปิด 21:00 น.
  static const int _maxHours = 8;

  static const _timeSlots = [
    '09:00', '10:00', '11:00', '12:00',
    '13:00', '14:00', '15:00', '16:00',
    '17:00', '18:00', '19:00', '20:00',
  ];

  static const _months = [
    'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
    'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
  ];

  Color get _primary => Theme.of(context).colorScheme.primary;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  // ---------- ตัวช่วยคำนวณ ----------

  String _formatDate(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year + 543}';

  int? get _startHour =>
      _selectedTime == null ? null : int.parse(_selectedTime!.split(':')[0]);

  int? get _endHour => _startHour == null ? null : _startHour! + _hours;

  String get _timeRangeText {
    final s = _startHour!.toString().padLeft(2, '0');
    final e = _endHour!.toString().padLeft(2, '0');
    return '$s:00 - $e:00 น.';
  }

  /// จำนวนชั่วโมงสูงสุดที่เลือกได้ ต้องไม่เกินเวลาปิด
  int get _maxSelectableHours {
    if (_startHour == null) return _maxHours;
    return (_closingHour - _startHour!).clamp(1, _maxHours);
  }

  // ---------- Actions ----------

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเลือกวันที่และเวลา')),
      );
      return;
    }

    if (_endHour! > _closingHour) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เวลาที่เลือกเกินเวลาปิดบริการ (21:00 น.)'),
        ),
      );
      return;
    }

    // TODO: ส่งข้อมูลไปบันทึกที่ API / Firebase ตรงนี้
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('จองสำเร็จ'),
        content: Text(
          '${_formatDate(_selectedDate!)}\n'
          '$_timeRangeText ($_hours ชั่วโมง)\n'
          'จำนวน $_guests คน',
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushReplacementNamed(context, '/my-booking');
              },
              child: const Text('ดูรายการจองของฉัน'),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('จองคิว'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              _sectionTitle('เลือกวันที่'),
              _buildDateCard(),
              const SizedBox(height: 24),
              _sectionTitle('เลือกเวลาเริ่ม'),
              _buildTimeSlots(),
              const SizedBox(height: 24),
              _sectionTitle('ระยะเวลา'),
              _buildHoursPicker(),
              const SizedBox(height: 24),
              _sectionTitle('จำนวนคน'),
              _buildGuestCounter(),
              const SizedBox(height: 24),
              _sectionTitle('ข้อมูลผู้จอง'),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('ชื่อ-นามสกุล', Icons.person),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'กรุณากรอกชื่อ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('เบอร์โทรศัพท์', Icons.phone),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'กรุณากรอกเบอร์โทร';
                  if (v.trim().length < 9) return 'เบอร์โทรไม่ถูกต้อง';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                decoration:
                    _inputDecoration('หมายเหตุ (ถ้ามี)', Icons.edit_note),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          child: SizedBox(
            height: 52,
            child: FilledButton(
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _submit,
              child: const Text(
                'ยืนยันการจอง',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      );

  InputDecoration _inputDecoration(String label, IconData icon) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  Widget _buildDateCard() {
    final hasDate = _selectedDate != null;
    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasDate ? _primary : Colors.grey.shade400,
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: _primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDate ? _formatDate(_selectedDate!) : 'แตะเพื่อเลือกวันที่',
                style: TextStyle(
                  fontSize: 15,
                  color: hasDate ? null : Colors.grey.shade600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlots() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _timeSlots.map((t) {
        return ChoiceChip(
          label: Text(t),
          selected: _selectedTime == t,
          onSelected: (_) => setState(() {
            _selectedTime = t;
            // ถ้าชั่วโมงที่เลือกไว้เกินเวลาปิด ให้ลดลงอัตโนมัติ
            if (_hours > _maxSelectableHours) _hours = _maxSelectableHours;
          }),
        );
      }).toList(),
    );
  }

  Widget _buildHoursPicker() {
    final max = _maxSelectableHours;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 4),
              Icon(Icons.timer_outlined, color: _primary),
              const SizedBox(width: 12),
              const Expanded(child: Text('ระยะเวลาที่ต้องการ')),
              IconButton(
                onPressed: _hours > 1 ? () => setState(() => _hours--) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '$_hours ชม.',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed:
                    _hours < max ? () => setState(() => _hours++) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          if (_selectedTime != null) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'ช่วงเวลา: $_timeRangeText',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuestCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(Icons.people, color: _primary),
          const SizedBox(width: 12),
          const Expanded(child: Text('จำนวนผู้เข้าใช้บริการ')),
          IconButton(
            onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text(
            '$_guests',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          IconButton(
            onPressed: _guests < 20 ? () => setState(() => _guests++) : null,
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
    );
  }
}