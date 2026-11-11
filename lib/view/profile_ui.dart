import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_massage/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Theme constants
// ---------------------------------------------------------------------------
class _AppColors {
  static const Color primaryGreen = ZenTouchColors.primary;
  static const Color darkGreen = ZenTouchColors.primaryDark;
  static const Color cream = ZenTouchColors.background;
  static const Color cardWhite = ZenTouchColors.surface;
  static const Color lightGreen = ZenTouchColors.surfaceSecondary;
  static const Color textMuted = ZenTouchColors.textSecondary;
  static const Color danger = ZenTouchColors.error;
  static const Color dangerLight = ZenTouchColors.errorContainer;
  static const Color gold = ZenTouchColors.warning;
  static const Color goldLight = ZenTouchColors.warningContainer;
  static const Color sage = ZenTouchColors.success;
}

TextStyle _prompt(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = _AppColors.darkGreen,
  double? height,
}) {
  return GoogleFonts.prompt(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

// ---------------------------------------------------------------------------
// Profile screen
// ---------------------------------------------------------------------------
class ProfileUi extends StatefulWidget {
  const ProfileUi({super.key});

  @override
  State<ProfileUi> createState() => _ProfileUiState();
}

class _ProfileUiState extends State<ProfileUi> {
  // ----- Mock data -----
  String _fullName = 'รัตนากร สุระ';
  String _phone = '081-234-5678';
  String _email = 'customer@email.com';
  DateTime _birthDate = DateTime(1996, 5, 14);
  String _gender = 'หญิง';
  final String _membership = 'สมาชิกทั่วไป';

  final int _serviceCount = 12;
  final int _upcomingBookings = 2;
  final int _points = 480;

  // ----- Settings state -----
  bool _notificationsEnabled = true;
  bool _bookingReminderEnabled = true;

  // ----- Avatar presets (mock profile photos) -----
  int _avatarIndex = 0;
  static const List<_AvatarPreset> _avatarPresets = [
    _AvatarPreset(Icons.spa_rounded, ZenTouchColors.surfaceSecondary),
    _AvatarPreset(
      Icons.self_improvement_rounded,
      ZenTouchColors.warningContainer,
    ),
    _AvatarPreset(Icons.local_florist_rounded, ZenTouchColors.blushContainer),
    _AvatarPreset(Icons.face_rounded, ZenTouchColors.lavenderContainer),
  ];

  static const List<String> _thaiMonths = [
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

  String _formatThaiDate(DateTime d) {
    return '${d.day} ${_thaiMonths[d.month - 1]} ${d.year + 543}';
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: _prompt(14, color: Colors.white)),
          backgroundColor: _AppColors.darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _showComingSoon(String title) {
    _showSnack('เมนู "$title" อยู่ระหว่างการพัฒนา');
  }

  // -------------------------------------------------------------------------
  // Validation
  // -------------------------------------------------------------------------
  String? _validateName(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'กรุณากรอกชื่อ-นามสกุล';
    if (text.length < 2) return 'ชื่อ-นามสกุลสั้นเกินไป';
    return null;
  }

  String? _validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
    if (digits.length != 10 || !digits.startsWith('0')) {
      return 'เบอร์โทรศัพท์ต้องมี 10 หลักและขึ้นต้นด้วย 0';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'กรุณากรอกอีเมล';
    final regex = RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+$');
    if (!regex.hasMatch(text)) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  String _formatPhone(String input) {
    final d = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 10) return input;
    return '${d.substring(0, 3)}-${d.substring(3, 6)}-${d.substring(6)}';
  }

  // -------------------------------------------------------------------------
  // Edit actions
  // -------------------------------------------------------------------------
  Future<String?> _openEditSheet({
    required String title,
    required String label,
    required String initialValue,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _EditFieldSheet(
          title: title,
          label: label,
          initialValue: initialValue,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
        );
      },
    );
  }

  Future<void> _editName() async {
    final result = await _openEditSheet(
      title: 'แก้ไขชื่อ-นามสกุล',
      label: 'ชื่อ-นามสกุล',
      initialValue: _fullName,
      validator: _validateName,
    );
    if (result != null && mounted) {
      setState(() => _fullName = result.trim());
      _showSnack('บันทึกชื่อ-นามสกุลเรียบร้อยแล้ว');
    }
  }

  Future<void> _editPhone() async {
    final result = await _openEditSheet(
      title: 'แก้ไขเบอร์โทรศัพท์',
      label: 'เบอร์โทรศัพท์',
      initialValue: _phone,
      validator: _validatePhone,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
        LengthLimitingTextInputFormatter(12),
      ],
    );
    if (result != null && mounted) {
      setState(() => _phone = _formatPhone(result));
      _showSnack('บันทึกเบอร์โทรศัพท์เรียบร้อยแล้ว');
    }
  }

  Future<void> _editEmail() async {
    final result = await _openEditSheet(
      title: 'แก้ไขอีเมล',
      label: 'อีเมล',
      initialValue: _email,
      validator: _validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
    if (result != null && mounted) {
      setState(() => _email = result.trim());
      _showSnack('บันทึกอีเมลเรียบร้อยแล้ว');
    }
  }

  Future<void> _editBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'เลือกวันเกิด',
      cancelText: 'ยกเลิก',
      confirmText: 'บันทึก',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _AppColors.primaryGreen,
              onPrimary: Colors.white,
              surface: _AppColors.cardWhite,
              onSurface: _AppColors.darkGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() => _birthDate = picked);
      _showSnack('บันทึกวันเกิดเรียบร้อยแล้ว');
    }
  }

  Future<void> _editGender() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: _AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _GenderSheet(currentValue: _gender);
      },
    );
    if (result != null && mounted) {
      setState(() => _gender = result);
      _showSnack('บันทึกเพศเรียบร้อยแล้ว');
    }
  }

  Future<void> _changeAvatar() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: _AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 16),
                Text(
                  'เปลี่ยนรูปโปรไฟล์',
                  style: _prompt(18, weight: FontWeight.w600),
                ),
                Text(
                  'Change profile picture',
                  style: _prompt(12, color: _AppColors.textMuted),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_avatarPresets.length, (index) {
                    final preset = _avatarPresets[index];
                    final selected = index == _avatarIndex;
                    return GestureDetector(
                      onTap: () => Navigator.pop(sheetContext, index),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: preset.background,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                selected
                                    ? _AppColors.primaryGreen
                                    : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          preset.icon,
                          color: _AppColors.primaryGreen,
                          size: 30,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (result != null && mounted) {
      setState(() => _avatarIndex = result);
      _showSnack('เปลี่ยนรูปโปรไฟล์เรียบร้อยแล้ว');
    }
  }

  // -------------------------------------------------------------------------
  // Logout
  // -------------------------------------------------------------------------
  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'ออกจากระบบ',
            style: _prompt(18, weight: FontWeight.w600),
          ),
          content: Text(
            'คุณต้องการออกจากระบบ MASSAGE AI ใช่หรือไม่?',
            style: _prompt(14, color: _AppColors.textMuted, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(
                'ยกเลิก',
                style: _prompt(14, color: _AppColors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(
                'ออกจากระบบ',
                style: _prompt(
                  14,
                  weight: FontWeight.w600,
                  color: _AppColors.danger,
                ),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed == true && mounted) {
      _showSnack('ออกจากระบบเรียบร้อยแล้ว (Mock)');
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.cream,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileHeader(),
              const SizedBox(height: 16),
              _buildSummaryRow(),
              const SizedBox(height: 24),
              const _SectionTitle(
                title: 'ข้อมูลส่วนตัว',
                subtitle: 'Personal Information',
              ),
              _buildPersonalInfoCard(),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'บัญชีของฉัน', subtitle: 'My Account'),
              _buildAccountCard(),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'การตั้งค่า', subtitle: 'Settings'),
              _buildSettingsCard(),
              const SizedBox(height: 24),
              const _SectionTitle(
                title: 'ช่วยเหลือ',
                subtitle: 'Help & Support',
              ),
              _buildHelpCard(),
              const SizedBox(height: 28),
              _buildLogoutButton(),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'MASSAGE AI เวอร์ชัน 1.0.0',
                  style: _prompt(12, color: _AppColors.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ----- AppBar -----
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _AppColors.cream,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 72,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('โปรไฟล์ของฉัน', style: _prompt(20, weight: FontWeight.w600)),
          Text('My Profile', style: _prompt(12, color: _AppColors.textMuted)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Container(
            decoration: const BoxDecoration(
              color: _AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'ตั้งค่า',
              icon: const Icon(
                Icons.settings_outlined,
                color: _AppColors.primaryGreen,
              ),
              onPressed: () => _showComingSoon('ตั้งค่า'),
            ),
          ),
        ),
      ],
    );
  }

  // ----- Profile header -----
  Widget _buildProfileHeader() {
    final preset = _avatarPresets[_avatarIndex];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_AppColors.darkGreen, _AppColors.primaryGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _AppColors.darkGreen.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: preset.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Icon(
                  preset.icon,
                  size: 40,
                  color: _AppColors.primaryGreen,
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: GestureDetector(
                  onTap: _changeAvatar,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _AppColors.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 15,
                      color: _AppColors.primaryGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _prompt(
                    18,
                    weight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                _HeaderInfoRow(icon: Icons.email_outlined, text: _email),
                const SizedBox(height: 2),
                _HeaderInfoRow(icon: Icons.phone_outlined, text: _phone),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.workspace_premium_outlined,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _membership,
                        style: _prompt(
                          12,
                          weight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- Summary -----
  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.spa_outlined,
            value: '$_serviceCount',
            label: 'ครั้งที่ใช้บริการ',
            accent: _AppColors.primaryGreen,
            background: _AppColors.lightGreen,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.event_available_outlined,
            value: '$_upcomingBookings',
            label: 'การจองที่จะถึง',
            accent: _AppColors.sage,
            background: ZenTouchColors.surfaceSecondary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.stars_rounded,
            value: '$_points',
            label: 'คะแนนสะสม',
            accent: _AppColors.gold,
            background: _AppColors.goldLight,
          ),
        ),
      ],
    );
  }

  // ----- Personal info -----
  Widget _buildPersonalInfoCard() {
    return _SectionCard(
      children: [
        _InfoTile(
          icon: Icons.person_outline_rounded,
          label: 'ชื่อ-นามสกุล',
          value: _fullName,
          onEdit: _editName,
        ),
        const _TileDivider(),
        _InfoTile(
          icon: Icons.phone_outlined,
          label: 'เบอร์โทรศัพท์',
          value: _phone,
          onEdit: _editPhone,
        ),
        const _TileDivider(),
        _InfoTile(
          icon: Icons.email_outlined,
          label: 'อีเมล',
          value: _email,
          onEdit: _editEmail,
        ),
        const _TileDivider(),
        _InfoTile(
          icon: Icons.cake_outlined,
          label: 'วันเกิด',
          value: _formatThaiDate(_birthDate),
          onEdit: _editBirthDate,
        ),
        const _TileDivider(),
        _InfoTile(
          icon: Icons.wc_rounded,
          label: 'เพศ',
          value: _gender,
          onEdit: _editGender,
        ),
      ],
    );
  }

  // ----- Account -----
  Widget _buildAccountCard() {
    return _SectionCard(
      children: [
        _MenuTile(
          icon: Icons.lock_outline_rounded,
          title: 'เปลี่ยนรหัสผ่าน',
          subtitle: 'Change Password',
          onTap: () => _showComingSoon('เปลี่ยนรหัสผ่าน'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.location_on_outlined,
          title: 'ที่อยู่สำหรับรับบริการ',
          subtitle: 'Service Address (Outcall)',
          onTap: () => _showComingSoon('ที่อยู่สำหรับรับบริการ'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.history_rounded,
          title: 'ประวัติการใช้บริการ',
          subtitle: 'Service History',
          onTap: () => _showComingSoon('ประวัติการใช้บริการ'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.favorite_border_rounded,
          title: 'รายการโปรด',
          subtitle: 'Favorites',
          onTap: () => _showComingSoon('รายการโปรด'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.notifications_none_rounded,
          title: 'การแจ้งเตือน',
          subtitle: 'Notifications',
          onTap: () => _showComingSoon('การแจ้งเตือน'),
        ),
      ],
    );
  }

  // ----- Settings -----
  Widget _buildSettingsCard() {
    return _SectionCard(
      children: [
        _SwitchTile(
          icon: Icons.notifications_active_outlined,
          title: 'เปิด/ปิดการแจ้งเตือน',
          subtitle: 'Push Notifications',
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
              if (!value) _bookingReminderEnabled = false;
            });
            _showSnack(value ? 'เปิดการแจ้งเตือนแล้ว' : 'ปิดการแจ้งเตือนแล้ว');
          },
        ),
        const _TileDivider(),
        _SwitchTile(
          icon: Icons.alarm_rounded,
          title: 'แจ้งเตือนก่อนถึงเวลาจอง',
          subtitle: 'Booking Reminder',
          value: _bookingReminderEnabled,
          enabled: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _bookingReminderEnabled = value);
            _showSnack(
              value
                  ? 'จะแจ้งเตือนก่อนถึงเวลาจอง'
                  : 'ปิดการแจ้งเตือนก่อนถึงเวลาจองแล้ว',
            );
          },
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.privacy_tip_outlined,
          title: 'นโยบายความเป็นส่วนตัว',
          subtitle: 'Privacy Policy',
          onTap: () => _showComingSoon('นโยบายความเป็นส่วนตัว'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.description_outlined,
          title: 'เงื่อนไขการใช้บริการ',
          subtitle: 'Terms of Service',
          onTap: () => _showComingSoon('เงื่อนไขการใช้บริการ'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.info_outline_rounded,
          title: 'เกี่ยวกับ MASSAGE AI',
          subtitle: 'About MASSAGE AI',
          onTap: () => _showComingSoon('เกี่ยวกับ MASSAGE AI'),
        ),
      ],
    );
  }

  // ----- Help -----
  Widget _buildHelpCard() {
    return _SectionCard(
      children: [
        _MenuTile(
          icon: Icons.storefront_outlined,
          title: 'ติดต่อร้าน',
          subtitle: 'Contact Shop',
          onTap: () => _showComingSoon('ติดต่อร้าน'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.help_outline_rounded,
          title: 'คำถามที่พบบ่อย (FAQ)',
          subtitle: 'Frequently Asked Questions',
          onTap: () => _showComingSoon('คำถามที่พบบ่อย'),
        ),
        const _TileDivider(),
        _MenuTile(
          icon: Icons.smart_toy,
          title: 'ติดต่อ AI Assistant',
          subtitle: 'Chat with AI Assistant',
          onTap: () => _showComingSoon('AI Assistant'),
        ),
      ],
    );
  }

  // ----- Logout -----
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: _confirmLogout,
        icon: const Icon(Icons.logout_rounded, color: _AppColors.danger),
        label: Text(
          'ออกจากระบบ',
          style: _prompt(16, weight: FontWeight.w600, color: _AppColors.danger),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.dangerLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: _AppColors.danger.withValues(alpha: 0.25)),
          ),
        ),
      ),
    );
  }

  // ----- Bottom navigation -----
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.cardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: _AppColors.cardWhite,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: _AppColors.primaryGreen,
        unselectedItemColor: _AppColors.textMuted,
        selectedLabelStyle: _prompt(12, weight: FontWeight.w600),
        unselectedLabelStyle: _prompt(12),
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/my-booking');
              break;
            case 2:
              break; // อยู่หน้าเดิม
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined),
            activeIcon: Icon(Icons.calendar_month_rounded),
            label: 'การจอง',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'โปรไฟล์',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Data class
// ---------------------------------------------------------------------------
class _AvatarPreset {
  final IconData icon;
  final Color background;

  const _AvatarPreset(this.icon, this.background);
}

// ---------------------------------------------------------------------------
// Reusable widgets
// ---------------------------------------------------------------------------
class _HeaderInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeaderInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.white70),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _prompt(12.5, color: Colors.white70),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;
  final Color background;

  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: _AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZenTouchColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: _prompt(
              22,
              weight: FontWeight.w700,
              color: ZenTouchColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: _prompt(11.5, color: _AppColors.textMuted, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(title, style: _prompt(16, weight: FontWeight.w600)),
          const SizedBox(width: 8),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: _prompt(12, color: _AppColors.textMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final List<Widget> children;

  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _AppColors.cardWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 68,
      endIndent: 16,
      color: ZenTouchColors.border,
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;

  const _IconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: _AppColors.lightGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: _AppColors.primaryGreen, size: 21),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onEdit;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _IconBadge(icon: icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: _prompt(12, color: _AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _prompt(14.5, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'แก้ไข$label',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.edit_outlined,
              size: 20,
              color: _AppColors.primaryGreen,
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _prompt(14.5, weight: FontWeight.w500),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _prompt(11.5, color: _AppColors.textMuted),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: _AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _IconBadge(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _prompt(14.5, weight: FontWeight.w500),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _prompt(11.5, color: _AppColors.textMuted),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeThumbColor: Colors.white,
              activeTrackColor: _AppColors.primaryGreen,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: ZenTouchColors.border,
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 44,
        height: 4,
        decoration: BoxDecoration(
          color: ZenTouchColors.border,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet: edit a text field with validation
// ---------------------------------------------------------------------------
class _EditFieldSheet extends StatefulWidget {
  final String title;
  final String label;
  final String initialValue;
  final String? Function(String?) validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _EditFieldSheet({
    required this.title,
    required this.label,
    required this.initialValue,
    required this.validator,
    required this.keyboardType,
    this.inputFormatters,
  });

  @override
  State<_EditFieldSheet> createState() => _EditFieldSheetState();
}

class _EditFieldSheetState extends State<_EditFieldSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SheetHandle(),
                const SizedBox(height: 16),
                Text(widget.title, style: _prompt(18, weight: FontWeight.w600)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  validator: widget.validator,
                  style: _prompt(15),
                  cursorColor: _AppColors.primaryGreen,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: widget.label,
                    labelStyle: _prompt(14, color: _AppColors.textMuted),
                    errorStyle: _prompt(12, color: _AppColors.danger),
                    filled: true,
                    fillColor: _AppColors.cream,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _AppColors.primaryGreen,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: _AppColors.danger),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _AppColors.danger,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(
                            color: _AppColors.primaryGreen,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'ยกเลิก',
                          style: _prompt(
                            15,
                            weight: FontWeight.w500,
                            color: _AppColors.primaryGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: _AppColors.primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'บันทึก',
                          style: _prompt(
                            15,
                            weight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet: choose gender
// ---------------------------------------------------------------------------
class _GenderSheet extends StatefulWidget {
  final String currentValue;

  const _GenderSheet({required this.currentValue});

  @override
  State<_GenderSheet> createState() => _GenderSheetState();
}

class _GenderSheetState extends State<_GenderSheet> {
  static const List<String> _options = ['หญิง', 'ชาย', 'ไม่ระบุ'];
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentValue;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const SizedBox(height: 16),
            Text('แก้ไขเพศ', style: _prompt(18, weight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children:
                  _options.map((option) {
                    final selected = option == _selected;
                    return ChoiceChip(
                      label: Text(
                        option,
                        style: _prompt(
                          14,
                          color: selected ? Colors.white : _AppColors.darkGreen,
                        ),
                      ),
                      selected: selected,
                      selectedColor: _AppColors.primaryGreen,
                      backgroundColor: _AppColors.lightGreen,
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (_) => setState(() => _selected = option),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: _AppColors.primaryGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'ยกเลิก',
                      style: _prompt(
                        15,
                        weight: FontWeight.w500,
                        color: _AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: _AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'บันทึก',
                      style: _prompt(
                        15,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
