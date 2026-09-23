
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;
  bool _remember = true;

  static const green = Color(0xFF176B57);
  static const darkGreen = Color(0xFF0E4639);
  static const softGreen = Color(0xFFEAF5F1);
  static const ink = Color(0xFF172B26);
  static const muted = Color(0xFF70807B);
  static const border = Color(0xFFDDE7E3);

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('लॉगिन यशस्वी झाले.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.go('/');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      var message = 'लॉगिन करताना त्रुटी आली.';
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          message = 'ई-मेल किंवा पासवर्ड चुकीचा आहे.';
          break;
        case 'invalid-email':
          message = 'कृपया योग्य ई-मेल टाका.';
          break;
        case 'user-disabled':
          message = 'हा user account बंद करण्यात आला आहे.';
          break;
        case 'too-many-requests':
          message = 'खूप प्रयत्न झाले आहेत. थोड्या वेळाने पुन्हा प्रयत्न करा.';
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('अनपेक्षित त्रुटी आली. पुन्हा प्रयत्न करा.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final controller = TextEditingController(text: _email.text.trim());
    final value = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('पासवर्ड reset करा'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'ई-मेल',
            hintText: 'admin@example.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('रद्द करा'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Reset Link पाठवा'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (!mounted || value == null || value.isEmpty) return;
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: value);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link ई-मेलवर पाठवला आहे.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = e.code == 'invalid-email'
          ? 'कृपया योग्य ई-मेल टाका.'
          : e.code == 'user-not-found'
              ? 'या ई-मेलसाठी account सापडला नाही.'
              : 'Password reset करताना त्रुटी आली.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 900) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      children: [
                        _brand(false),
                        const SizedBox(height: 24),
                        _card(),
                        const SizedBox(height: 22),
                        _footer(),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Row(
              children: [
                Expanded(flex: 48, child: _brandPanel()),
                Expanded(
                  flex: 52,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(48),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: _card(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _brandPanel() => Container(
        margin: const EdgeInsets.all(18),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: darkGreen,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -150,
              right: -120,
              child: _circle(360),
            ),
            Positioned(
              bottom: -180,
              left: -140,
              child: _circle(420),
            ),
            Positioned(
              right: 28,
              bottom: 28,
              child: Opacity(
                opacity: .07,
                child: Icon(Icons.agriculture_rounded,
                    size: 270, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(48, 42, 48, 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _brand(true),
                  const Spacer(),
                  const Text(
                    'सत्व धारा',
                    style: TextStyle(
                      fontSize: 52,
                      height: 1.05,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'डेअरी फार्म',
                    style: TextStyle(
                      fontSize: 31,
                      color: Colors.white.withValues(alpha: .88),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Container(
                    width: 64,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF70D1B4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Farm Management ERP',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'दूध संकलन, जनावरे, खर्च, इन्व्हेंटरी आणि रिपोर्ट्सचे '
                    'सोपे व स्मार्ट व्यवस्थापन.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.65,
                      color: Colors.white.withValues(alpha: .68),
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _trust(Icons.cloud_done_rounded, 'Secure'),
                      const SizedBox(width: 22),
                      _trust(Icons.insights_rounded, 'Smart Reports'),
                      const SizedBox(width: 22),
                      _trust(Icons.devices_rounded, 'Desktop Ready'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _brand(bool light) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: light ? Colors.white.withValues(alpha: .12) : softGreen,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.agriculture_rounded,
              size: 29,
              color: light ? Colors.white : green,
            ),
          ),
          const SizedBox(width: 13),
          Text(
            'SATVA DHARA',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.7,
              color: light ? Colors.white : darkGreen,
            ),
          ),
        ],
      );

  Widget _card() => Container(
        padding: const EdgeInsets.fromLTRB(38, 36, 38, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .055),
              blurRadius: 35,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'स्वागत आहे!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: ink,
                            letterSpacing: -.7,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'तुमच्या फार्ममध्ये सुरक्षितपणे लॉगिन करा.',
                          style: TextStyle(
                            fontSize: 14.5,
                            color: muted,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(Icons.login_rounded, color: green),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _label('ई-मेल'),
              const SizedBox(height: 8),
              _emailField(),
              const SizedBox(height: 19),
              _label('पासवर्ड'),
              const SizedBox(height: 8),
              _passwordField(),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: Checkbox(
                      value: _remember,
                      activeColor: green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      onChanged: (v) => setState(() => _remember = v ?? false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'मला लक्षात ठेवा',
                    style: TextStyle(
                      fontSize: 13,
                      color: muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    style: TextButton.styleFrom(
                      foregroundColor: green,
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text(
                      'पासवर्ड विसरलात?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: green.withValues(alpha: .55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'लॉगिन करा',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(width: 9),
                            Icon(Icons.arrow_forward_rounded, size: 19),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                children: [
                  const Expanded(child: Divider(color: border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'SATVA DHARA ERP',
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.3,
                        fontWeight: FontWeight.w800,
                        color: muted,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: border)),
                ],
              ),
              const SizedBox(height: 17),
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, size: 17, color: green),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'तुमची login माहिती सुरक्षित authentication द्वारे हाताळली जाते.',
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.45,
                        color: muted,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: ink,
        ),
      );

  Widget _emailField() => TextFormField(
        controller: _email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.username],
        decoration: _decoration('admin@example.com', Icons.mail_outline_rounded),
        validator: (v) {
          final email = v?.trim() ?? '';
          if (email.isEmpty) return 'ई-मेल टाका';
          if (!email.contains('@')) return 'योग्य ई-मेल टाका';
          return null;
        },
      );

  Widget _passwordField() => TextFormField(
        controller: _password,
        obscureText: _obscure,
        textInputAction: TextInputAction.done,
        autofillHints: const [AutofillHints.password],
        onFieldSubmitted: (_) => _login(),
        decoration: _decoration('तुमचा पासवर्ड', Icons.lock_outline_rounded)
            .copyWith(
          suffixIcon: IconButton(
            tooltip: _obscure ? 'पासवर्ड दाखवा' : 'पासवर्ड लपवा',
            icon: Icon(
              _obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: muted,
              size: 20,
            ),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),
        validator: (v) =>
            v == null || v.isEmpty ? 'पासवर्ड टाका' : null,
      );

  InputDecoration _decoration(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFA0ADA9), fontSize: 13),
        prefixIcon: Icon(icon, color: muted, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAF9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: green, width: 1.5),
        ),
      );

  Widget _trust(IconData icon, String text) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: const Color(0xFF70D1B4)),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: .62),
            ),
          ),
        ],
      );

  Widget _circle(double size) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF2D8C72).withValues(alpha: .16),
        ),
      );

  Widget _footer() => const Text(
        'Satva Dhara ERP • Farm Management System',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          color: muted,
          fontWeight: FontWeight.w500,
        ),
      );
}
