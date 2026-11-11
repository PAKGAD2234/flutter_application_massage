import 'package:flutter/material.dart';
import 'package:flutter_application_massage/theme/app_theme.dart';

// ====================== Model ======================

class ServiceModel {
  final String id;
  final String name;
  final String category;
  final String description;
  final double price;
  final int durationMinutes;
  final int bufferMinutes;
  final String? imageUrl;
  final bool isActive;
  final List<String> therapists;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.bufferMinutes,
    this.imageUrl,
    this.isActive = true,
    this.therapists = const [],
  });

  ServiceModel copyWith({bool? isActive}) => ServiceModel(
    id: id,
    name: name,
    category: category,
    description: description,
    price: price,
    durationMinutes: durationMinutes,
    bufferMinutes: bufferMinutes,
    imageUrl: imageUrl,
    isActive: isActive ?? this.isActive,
    therapists: therapists,
  );
}

enum _StatusFilter { all, active, inactive }

enum _SortBy { name, priceAsc, priceDesc }

String _money(double v) {
  final s = v.toStringAsFixed(0);
  return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
}

// ====================== หน้าหลัก ======================

class ManageServiceUi extends StatefulWidget {
  const ManageServiceUi({super.key});

  @override
  State<ManageServiceUi> createState() => _ManageServiceUiState();
}

class _ManageServiceUiState extends State<ManageServiceUi> {
  static const _categories = ['นวดแผนไทย', 'นวดน้ำมัน', 'นวดเท้า', 'อื่น ๆ'];
  static const _allTherapists = [
    'พนักงาน A',
    'พนักงาน B',
    'พนักงาน C',
    'พนักงาน D',
  ];

  final _searchCtrl = TextEditingController();
  String _search = '';
  String _categoryFilter = 'ทั้งหมด';
  _StatusFilter _statusFilter = _StatusFilter.all;
  _SortBy _sortBy = _SortBy.name;

  // TODO: เปลี่ยนเป็นดึงข้อมูลจาก Supabase (ตาราง services)
  final List<ServiceModel> _services = [
    const ServiceModel(
      id: '1',
      name: 'นวดแผนไทย',
      category: 'นวดแผนไทย',
      description: 'นวดแผนไทยแบบดั้งเดิม คลายกล้ามเนื้อและเส้นตึง',
      price: 300,
      durationMinutes: 60,
      bufferMinutes: 15,
      isActive: true,
      therapists: ['พนักงาน A', 'พนักงาน B', 'พนักงาน C'],
    ),
    const ServiceModel(
      id: '2',
      name: 'นวดอโรม่า',
      category: 'นวดน้ำมัน',
      description: 'นวดน้ำมันหอมระเหย ผ่อนคลายทั้งร่างกายและจิตใจ',
      price: 600,
      durationMinutes: 90,
      bufferMinutes: 15,
      isActive: true,
      therapists: ['พนักงาน B', 'พนักงาน D'],
    ),
    const ServiceModel(
      id: '3',
      name: 'นวดเท้า',
      category: 'นวดเท้า',
      description: 'นวดกดจุดฝ่าเท้า ช่วยลดอาการเมื่อยล้า',
      price: 250,
      durationMinutes: 60,
      bufferMinutes: 10,
      isActive: false,
      therapists: ['พนักงาน A', 'พนักงาน C', 'พนักงาน D'],
    ),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ---------- ข้อมูลที่กรองแล้ว ----------

  List<ServiceModel> get _filtered {
    final list =
        _services.where((s) {
          final matchSearch = s.name.toLowerCase().contains(
            _search.trim().toLowerCase(),
          );
          final matchCat =
              _categoryFilter == 'ทั้งหมด' || s.category == _categoryFilter;
          final matchStatus = switch (_statusFilter) {
            _StatusFilter.all => true,
            _StatusFilter.active => s.isActive,
            _StatusFilter.inactive => !s.isActive,
          };
          return matchSearch && matchCat && matchStatus;
        }).toList();

    switch (_sortBy) {
      case _SortBy.name:
        list.sort((a, b) => a.name.compareTo(b.name));
      case _SortBy.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _SortBy.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
    }
    return list;
  }

  // ---------- Actions ----------

  void _toggleActive(ServiceModel s, bool value) {
    // TODO: update is_active ใน Supabase
    setState(() {
      final i = _services.indexWhere((e) => e.id == s.id);
      _services[i] = s.copyWith(isActive: value);
    });
  }

  Future<void> _openForm({ServiceModel? editing}) async {
    final result = await showModalBottomSheet<ServiceModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (_) => _ServiceFormSheet(
            editing: editing,
            categories: _categories,
            allTherapists: _allTherapists,
          ),
    );
    if (result == null) return;

    // TODO: insert / update ใน Supabase แล้วค่อย setState
    setState(() {
      if (editing == null) {
        _services.add(result);
      } else {
        final i = _services.indexWhere((e) => e.id == editing.id);
        _services[i] = result;
      }
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          editing == null ? 'เพิ่มบริการแล้ว' : 'บันทึกการแก้ไขแล้ว',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(ServiceModel s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            icon: const Icon(
              Icons.delete_forever,
              color: ZenTouchColors.error,
              size: 48,
            ),
            title: const Text('ลบบริการ'),
            content: Text(
              'ต้องการลบ "${s.name}" ใช่หรือไม่?\nลบแล้วกู้คืนไม่ได้',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('ยกเลิก'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 197, 53, 74),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('ลบ'),
              ),
            ],
          ),
    );
    if (ok != true) return;

    // TODO: delete ใน Supabase
    setState(() => _services.removeWhere((e) => e.id == s.id));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('ลบ "${s.name}" แล้ว')));
  }

  void _showDetail(ServiceModel s) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
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
                width: 100,
                child: Text(
                  label,
                  style: const TextStyle(color: ZenTouchColors.textSecondary),
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
              Text(
                s.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              _StatusChip(active: s.isActive),
              const SizedBox(height: 12),
              row(Icons.category, 'หมวดหมู่', s.category),
              row(Icons.payments, 'ราคา', '${_money(s.price)} บาท'),
              row(Icons.timer, 'ระยะเวลา', '${s.durationMinutes} นาที'),
              row(Icons.free_breakfast, 'เวลาพัก', '${s.bufferMinutes} นาที'),
              row(
                Icons.notes,
                'รายละเอียด',
                s.description.isEmpty ? '-' : s.description,
              ),
              row(
                Icons.people,
                'พนักงาน',
                s.therapists.isEmpty
                    ? 'ยังไม่ได้กำหนด'
                    : s.therapists.join(', '),
              ),
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
      appBar: AppBar(title: const Text('จัดการบริการ'), centerTitle: true),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            _buildStats(),
            const SizedBox(height: 20),
            _buildFilters(),
            const SizedBox(height: 16),
            Text(
              'รายการบริการ (${items.length})',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (items.isEmpty) _buildEmpty(),
            ...items.map(_buildServiceCard),
          ],
        ),
      ),
    );
  }

  // ---------- ส่วนที่ 1: Header ----------
  Widget _buildHeader() {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'จัดการบริการ',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 4),
              Text(
                'จัดการรายการบริการ ราคา และระยะเวลาของร้าน',
                style: TextStyle(color: ZenTouchColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: () => _openForm(),
          icon: const Icon(Icons.add),
          label: const Text('เพิ่มบริการ'),
        ),
      ],
    );
  }

  // ---------- ส่วนที่ 2: Dashboard ----------
  Widget _buildStats() {
    final total = _services.length;
    final active = _services.where((e) => e.isActive).length;
    final categoryCount = _services.map((e) => e.category).toSet().length;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _StatCard(
          icon: Icons.spa,
          color: ZenTouchColors.primary,
          label: 'บริการทั้งหมด',
          value: '$total',
          unit: 'รายการบริการ',
        ),
        _StatCard(
          icon: Icons.check_circle,
          color: ZenTouchColors.success,
          label: 'เปิดให้บริการ',
          value: '$active',
          unit: 'รายการ',
        ),
        _StatCard(
          icon: Icons.pause_circle,
          color: ZenTouchColors.error,
          label: 'ปิดให้บริการ',
          value: '${total - active}',
          unit: 'รายการ',
        ),
        _StatCard(
          icon: Icons.category,
          color: ZenTouchColors.warning,
          label: 'หมวดหมู่',
          value: '$categoryCount',
          unit: 'หมวดหมู่บริการ',
        ),
      ],
    );
  }

  // ---------- ส่วนที่ 3: ค้นหาและกรอง ----------
  Widget _buildFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchCtrl,
          onChanged: (v) => setState(() => _search = v),
          decoration: InputDecoration(
            hintText: 'ค้นหาชื่อบริการ',
            prefixIcon: const Icon(Icons.search),
            suffixIcon:
                _search.isEmpty
                    ? null
                    : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      },
                    ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue: _categoryFilter,
                isExpanded: true,
                decoration: _filterDecoration('หมวดหมู่'),
                items:
                    ['ทั้งหมด', ..._categories]
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => _categoryFilter = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<_StatusFilter>(
                initialValue: _statusFilter,
                isExpanded: true,
                decoration: _filterDecoration('สถานะ'),
                items: const [
                  DropdownMenuItem(
                    value: _StatusFilter.all,
                    child: Text('ทั้งหมด'),
                  ),
                  DropdownMenuItem(
                    value: _StatusFilter.active,
                    child: Text('เปิดบริการ'),
                  ),
                  DropdownMenuItem(
                    value: _StatusFilter.inactive,
                    child: Text('ปิดบริการ'),
                  ),
                ],
                onChanged: (v) => setState(() => _statusFilter = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('เรียงตาม:'),
            ChoiceChip(
              label: const Text('ชื่อ'),
              selected: _sortBy == _SortBy.name,
              onSelected: (_) => setState(() => _sortBy = _SortBy.name),
            ),
            ChoiceChip(
              label: const Text('ราคาต่ำ → สูง'),
              selected: _sortBy == _SortBy.priceAsc,
              onSelected: (_) => setState(() => _sortBy = _SortBy.priceAsc),
            ),
            ChoiceChip(
              label: const Text('ราคาสูง → ต่ำ'),
              selected: _sortBy == _SortBy.priceDesc,
              onSelected: (_) => setState(() => _sortBy = _SortBy.priceDesc),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _filterDecoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  );

  // ---------- ส่วนที่ 4: การ์ดบริการ ----------
  Widget _buildServiceCard(ServiceModel s) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: ZenTouchColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 8, 6),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: scheme.primaryContainer,
                    child:
                        s.imageUrl != null
                            ? Image.network(
                              s.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.spa,
                                    color: scheme.primary,
                                    size: 32,
                                  ),
                            )
                            : Icon(Icons.spa, color: scheme.primary, size: 32),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'หมวดหมู่: ${s.category}',
                        style: TextStyle(
                          color: ZenTouchColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_money(s.price)} บาท',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'ระยะเวลา ${s.durationMinutes} นาที',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Switch(
                      value: s.isActive,
                      onChanged: (v) => _toggleActive(s, v),
                    ),
                    _StatusChip(active: s.isActive),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showDetail(s),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('รายละเอียด'),
                ),
                TextButton.icon(
                  onPressed: () => _openForm(editing: s),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('แก้ไข'),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: ZenTouchColors.error,
                  ),
                  onPressed: () => _confirmDelete(s),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('ลบ'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 40),
    child: Column(
      children: [
        Icon(Icons.search_off, size: 56, color: ZenTouchColors.primaryLight),
        const SizedBox(height: 8),
        Text(
          'ไม่พบบริการที่ค้นหา',
          style: const TextStyle(color: ZenTouchColors.textSecondary),
        ),
      ],
    ),
  );
}

// ====================== Widgets ย่อย ======================

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String unit;

  const _StatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: ZenTouchColors.primaryDark, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: ZenTouchColors.textPrimary,
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
                  color: ZenTouchColors.primaryDark,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 12,
                    color: ZenTouchColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final bool active;
  const _StatusChip({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? ZenTouchColors.success : ZenTouchColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ZenTouchColors.border),
      ),
      child: Text(
        active ? 'เปิดบริการ' : 'ปิดบริการ',
        style: TextStyle(
          color: ZenTouchColors.textPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ====================== ฟอร์มเพิ่ม / แก้ไข ======================

class _ServiceFormSheet extends StatefulWidget {
  final ServiceModel? editing;
  final List<String> categories;
  final List<String> allTherapists;

  const _ServiceFormSheet({
    required this.editing,
    required this.categories,
    required this.allTherapists,
  });

  @override
  State<_ServiceFormSheet> createState() => _ServiceFormSheetState();
}

class _ServiceFormSheetState extends State<_ServiceFormSheet> {
  static const _durations = [30, 60, 90, 120];
  static const _buffers = [0, 10, 15, 30];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _descCtrl;

  String? _category;
  late int _duration;
  late int _buffer;
  late bool _isActive;
  late Set<String> _therapists;

  bool get _isEdit => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl = TextEditingController(
      text: e == null ? '' : e.price.toStringAsFixed(0),
    );
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _category = e?.category;
    _duration = e?.durationMinutes ?? 60;
    _buffer = e?.bufferMinutes ?? 15;
    _isActive = e?.isActive ?? true;
    _therapists = {...?e?.therapists};
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
  );

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final model = ServiceModel(
      id:
          widget.editing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameCtrl.text.trim(),
      category: _category!,
      description: _descCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      durationMinutes: _duration,
      bufferMinutes: _buffer,
      imageUrl: widget.editing?.imageUrl,
      isActive: _isActive,
      therapists:
          widget.allTherapists.where((t) => _therapists.contains(t)).toList(),
    );
    Navigator.pop(context, model);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEdit ? 'แก้ไขบริการ' : 'เพิ่มบริการใหม่',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16),

              // รูปภาพ
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  // TODO: ใช้แพ็กเกจ image_picker เลือกรูป แล้วอัปโหลดไป Supabase Storage
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ยังไม่ได้ต่อระบบอัปโหลดรูป')),
                  );
                },
                child: Container(
                  height: 110,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: scheme.primary),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 34,
                        color: scheme.primary,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'เพิ่มรูปภาพบริการ',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'รองรับ JPG, PNG',
                        style: TextStyle(
                          fontSize: 12,
                          color: ZenTouchColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                decoration: _dec('ชื่อบริการ', hint: 'เช่น นวดแผนไทย'),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'กรุณากรอกชื่อบริการ'
                            : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _dec('หมวดหมู่'),
                items:
                    widget.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                onChanged: (v) => setState(() => _category = v),
                validator: (v) => v == null ? 'กรุณาเลือกหมวดหมู่' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                decoration: _dec('ราคา (บาท)', hint: '300'),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim());
                  if (n == null) return 'กรุณากรอกราคาเป็นตัวเลข';
                  if (n <= 0) return 'ราคาต้องมากกว่า 0';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _duration,
                      isExpanded: true,
                      decoration: _dec('ระยะเวลา'),
                      items:
                          _durations
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('$d นาที'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _duration = v!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _buffer,
                      isExpanded: true,
                      decoration: _dec('เวลาพัก'),
                      items:
                          _buffers
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('$d นาที'),
                                ),
                              )
                              .toList(),
                      onChanged: (v) => setState(() => _buffer = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: _dec(
                  'รายละเอียดบริการ',
                  hint: 'อธิบายรายละเอียดบริการ...',
                ),
              ),
              const SizedBox(height: 16),

              // ส่วนที่ 6: กำหนดพนักงาน
              const Text(
                'พนักงานที่ให้บริการ',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'ระบบจองและ AI จะแนะนำเฉพาะพนักงานที่เลือกไว้',
                style: const TextStyle(
                  fontSize: 12,
                  color: ZenTouchColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    widget.allTherapists.map((t) {
                      final selected = _therapists.contains(t);
                      return FilterChip(
                        label: Text(t),
                        selected: selected,
                        onSelected:
                            (v) => setState(() {
                              v ? _therapists.add(t) : _therapists.remove(t);
                            }),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 8),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('เปิดให้บริการ'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 8),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _save,
                  child: Text(
                    _isEdit ? 'บันทึกการแก้ไข' : 'บันทึกบริการ',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
