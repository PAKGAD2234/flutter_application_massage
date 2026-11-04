import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ---------------------------------------------------------------------------
// Theme constants
// ---------------------------------------------------------------------------
class _AppColors {
  static const Color primaryGreen = Color(0xFF426B55);
  static const Color darkGreen = Color(0xFF294C3A);
  static const Color cream = Color(0xFFF7F6F0);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color lightGreen = Color(0xFFE7EFE8);
  static const Color textDark = Color(0xFF26382D);
  static const Color textGrey = Color(0xFF858585);
  static const Color borderGrey = Color(0xFFDDDDD5);
  static const Color error = Color(0xFFB3412F);
}

TextStyle _prompt(
  double size, {
  FontWeight weight = FontWeight.w400,
  Color color = _AppColors.textDark,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.prompt(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

// ---------------------------------------------------------------------------
// Login screen
// ---------------------------------------------------------------------------
class LoginUi extends StatefulWidget {
  const LoginUi({super.key});

  @override
  State<LoginUi> createState() => _LoginUiState();
}

class _LoginUiState extends State<LoginUi> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;

  static final RegExp _emailRegex =
      RegExp(r'^[\w.+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: _prompt(14, color: Colors.white)),
          backgroundColor:
              isError ? _AppColors.error : _AppColors.darkGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // -------------------------------------------------------------------------
  // Validators
  // -------------------------------------------------------------------------
  String? _validateEmail(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'กรุณากรอกอีเมล';
    if (!_emailRegex.hasMatch(text)) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  String? _validatePassword(String? value) {
    if ((value ?? '').isEmpty) return 'กรุณากรอกรหัสผ่าน';
    return null;
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------
  Future<void> _handleLogin() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) {
      _showSnack('กรุณากรอกข้อมูลให้ครบถ้วนและถูกต้อง', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Mock login: จำลองการเรียก API (เชื่อม Supabase ภายหลัง)
    // TODO: แทนที่ด้วย Supabase.instance.client.auth.signInWithPassword(...)
    await Future<void>.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnack('เข้าสู่ระบบสำเร็จ');
    Navigator.pushReplacementNamed(context, '/home');
  }

  Future<void> _openForgotPassword() async {
    final sent = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: _AppColors.cardWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _ForgotPasswordSheet(
          initialEmail: _emailController.text.trim(),
          validator: _validateEmail,
        );
      },
    );
    if (sent != null && mounted) {
      _showSnack('ส่งคำขอรีเซ็ตรหัสผ่านไปที่ $sent แล้ว (Mock)');
    }
  }

  void _handleGoogleLogin() {
    _showSnack('การเข้าสู่ระบบด้วย Google อยู่ระหว่างพัฒนา');
  }

  Future<void> _showRegisterDialog() {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _AppColors.cardWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.construction_rounded,
            color: _AppColors.primaryGreen,
            size: 32,
          ),
          title: Text(
            'สมัครสมาชิก',
            textAlign: TextAlign.center,
            style: _prompt(18, weight: FontWeight.w600),
          ),
          content: Text(
            'ส่วนสมัครสมาชิกกำลังอยู่ระหว่างการพัฒนา\nโปรดรอติดตามเร็วๆ นี้',
            textAlign: TextAlign.center,
            style: _prompt(14, color: _AppColors.textGrey, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'ตกลง',
                style: _prompt(
                  15,
                  weight: FontWeight.w600,
                  color: _AppColors.primaryGreen,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.cream,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _BrandLogo(),
                    const SizedBox(height: 32),
                    _buildWelcomeText(),
                    const SizedBox(height: 24),
                    _buildLoginForm(),
                    const SizedBox(height: 8),
                    _buildRememberRow(),
                    const SizedBox(height: 16),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildGoogleButton(),
                    const SizedBox(height: 24),
                    _buildRegisterRow(),
                    const SizedBox(height: 16),
                    Text(
                      'Your Relaxation, Our Priority',
                      textAlign: TextAlign.center,
                      style: _prompt(
                        12,
                        color: _AppColors.textGrey,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'ยินดีต้อนรับกลับมา',
          textAlign: TextAlign.center,
          style: _prompt(24, weight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'เข้าสู่ระบบเพื่อจองบริการและดูแลช่วงเวลาพักผ่อนของคุณ',
          textAlign: TextAlign.center,
          style: _prompt(14, color: _AppColors.textGrey, height: 1.5),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            enabled: !_isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autocorrect: false,
            validator: _validateEmail,
            style: _prompt(15),
            cursorColor: _AppColors.primaryGreen,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            decoration: _inputDecoration(
              label: 'อีเมล',
              hint: 'example@email.com',
              icon: Icons.email_outlined,
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            enabled: !_isLoading,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: _validatePassword,
            style: _prompt(15),
            cursorColor: _AppColors.primaryGreen,
            onFieldSubmitted: (_) => _handleLogin(),
            decoration: _inputDecoration(
              label: 'รหัสผ่าน',
              hint: 'กรอกรหัสผ่านของคุณ',
              icon: Icons.lock_outline,
              suffix: IconButton(
                tooltip: _obscurePassword ? 'แสดงรหัสผ่าน' : 'ซ่อนรหัสผ่าน',
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: _AppColors.textGrey,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: _prompt(14, color: _AppColors.textGrey),
      floatingLabelStyle: _prompt(14, color: _AppColors.primaryGreen),
      hintStyle: _prompt(14, color: const Color(0xFFB5B5B5)),
      errorStyle: _prompt(12, color: _AppColors.error),
      prefixIcon: Icon(icon, color: _AppColors.primaryGreen),
      suffixIcon: suffix,
      filled: true,
      fillColor: _AppColors.cardWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border(_AppColors.borderGrey),
      enabledBorder: border(_AppColors.borderGrey),
      disabledBorder: border(_AppColors.borderGrey),
      focusedBorder: border(_AppColors.primaryGreen, 1.6),
      errorBorder: border(_AppColors.error),
      focusedErrorBorder: border(_AppColors.error, 1.6),
    );
  }

  Widget _buildRememberRow() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _isLoading
                ? null
                : () => setState(() => _rememberMe = !_rememberMe),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: Checkbox(
                    value: _rememberMe,
                    activeColor: _AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    side: const BorderSide(
                      color: _AppColors.textGrey,
                      width: 1.2,
                    ),
                    onChanged: _isLoading
                        ? null
                        : (value) =>
                            setState(() => _rememberMe = value ?? false),
                  ),
                ),
                Flexible(
                  child: Text(
                    'จดจำฉันไว้',
                    overflow: TextOverflow.ellipsis,
                    style: _prompt(13.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _openForgotPassword,
          child: Text(
            'ลืมรหัสผ่าน?',
            style: _prompt(
              13.5,
              weight: FontWeight.w500,
              color: _AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: _AppColors.primaryGreen,
          disabledBackgroundColor: _AppColors.primaryGreen.withOpacity(0.7),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'เข้าสู่ระบบ',
                style: _prompt(
                  16,
                  weight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: _AppColors.borderGrey)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'หรือเข้าสู่ระบบด้วย',
            style: _prompt(12.5, color: _AppColors.textGrey),
          ),
        ),
        const Expanded(child: Divider(color: _AppColors.borderGrey)),
      ],
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      height: 52,
      child: OutlinedButton(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        style: OutlinedButton.styleFrom(
          backgroundColor: _AppColors.cardWhite,
          side: const BorderSide(color: _AppColors.borderGrey),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _GoogleMark(),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'เข้าสู่ระบบด้วย Google',
                overflow: TextOverflow.ellipsis,
                style: _prompt(15, weight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterRow() {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'ยังไม่มีบัญชีใช่ไหม?',
          style: _prompt(14, color: _AppColors.textGrey),
        ),
        TextButton(
          onPressed: _isLoading ? null : _showRegisterDialog,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            minimumSize: const Size(0, 36),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'สมัครสมาชิก',
            style: _prompt(
              14,
              weight: FontWeight.w600,
              color: _AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Brand logo (เปลี่ยนเป็น Image Asset ได้ภายหลังโดยส่งค่า assetPath)
// ---------------------------------------------------------------------------
class _BrandLogo extends StatelessWidget {
  /// เช่น 'assets/images/logo.png' — ถ้าเป็น null จะใช้ไอคอนชั่วคราว
  final String? assetPath;

  const _BrandLogo({this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: _AppColors.lightGreen,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _AppColors.darkGreen.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: assetPath != null
              ? Padding(
                  padding: const EdgeInsets.all(18),
                  child: Image.asset(assetPath!, fit: BoxFit.contain),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: const [
                    Positioned(
                      top: 16,
                      child: Icon(
                        Icons.self_improvement_rounded,
                        size: 34,
                        color: _AppColors.primaryGreen,
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      child: Icon(
                        Icons.spa_rounded,
                        size: 40,
                        color: _AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 16),
        Text(
          'MASSAGE AI',
          style: _prompt(
            26,
            weight: FontWeight.w700,
            color: _AppColors.darkGreen,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'SPA & WELLNESS',
          style: _prompt(
            12,
            weight: FontWeight.w500,
            color: _AppColors.primaryGreen,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Google mark (ไม่มี Google icon ใน Material Icons จึงวาดตัว G ด้วย Widget)
// ---------------------------------------------------------------------------
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: _AppColors.borderGrey),
      ),
      child: Text(
        'G',
        style: GoogleFonts.prompt(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4285F4),
          height: 1.1,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet: forgot password
// ---------------------------------------------------------------------------
class _ForgotPasswordSheet extends StatefulWidget {
  final String initialEmail;
  final String? Function(String?) validator;

  const _ForgotPasswordSheet({
    required this.initialEmail,
    required this.validator,
  });

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.pop(context, _controller.text.trim());
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
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9DED9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ลืมรหัสผ่าน',
                  style: _prompt(18, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'กรอกอีเมลที่ใช้สมัคร เราจะส่งลิงก์สำหรับรีเซ็ตรหัสผ่านให้คุณ',
                  style: _prompt(13, color: _AppColors.textGrey, height: 1.5),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _controller,
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  validator: widget.validator,
                  style: _prompt(15),
                  cursorColor: _AppColors.primaryGreen,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'อีเมล',
                    hintText: 'example@email.com',
                    labelStyle: _prompt(14, color: _AppColors.textGrey),
                    hintStyle: _prompt(14, color: const Color(0xFFB5B5B5)),
                    errorStyle: _prompt(12, color: _AppColors.error),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: _AppColors.primaryGreen,
                    ),
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
                      borderSide: const BorderSide(color: _AppColors.error),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: _AppColors.error,
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
                          'ส่งคำขอ',
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