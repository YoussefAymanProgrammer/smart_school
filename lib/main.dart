// ============================================================
//  Smart School App — Flutter
//  supabase_flutter: ^2.5.0
//  assets: - assets/logo.png
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

// ==================== COLORS ====================
class AppColors {
  static const Color navy      = Color(0xFF0D2137);
  static const Color navyLight = Color(0xFF1A3A5C);
  static const Color navyCard  = Color(0xFF162D47);
  static const Color gold      = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFF8E7);
  static const Color goldSoft  = Color(0xFFF5E6A3);
  static const Color bg        = Color(0xFFF2F5F9);
  static const Color white     = Color(0xFFFFFFFF);
  static const Color green     = Color(0xFF1B8A4C);
  static const Color greenBg   = Color(0xFFE6F7EE);
  static const Color red       = Color(0xFFB91C1C);
  static const Color redBg     = Color(0xFFFEE2E2);
  static const Color orange    = Color(0xFFD97706);
  static const Color orangeBg  = Color(0xFFFEF3C7);
  static const Color grey      = Color(0xFF64748B);
  static const Color greyLight = Color(0xFFCBD5E1);
  static const Color blue      = Color(0xFF1D4ED8);
  static const Color blueBg    = Color(0xFFEFF6FF);
  static const Color purple    = Color(0xFF7C3AED);
  static const Color purpleBg  = Color(0xFFF5F3FF);
}

// ==================== STRINGS ====================
class AppStrings {
  static const String schoolName = 'مدرسة الطغمات السمائية للشمامسة';
  static const String churchName = 'كنيسة العذراء مريم والسمائين';
  static const String motto      = 'مدرسة تهدف لتعليم الألحان والطقوس الكنسية';
  static const List<String> yearNames = ['Year 1','Year 2','Year 3','Year 4','Year 5'];
}

// ==================== GLOBAL STATE ====================
Map<String, dynamic>? currentUser;
String? myClassId;
String? myClassCode;
String? myClassName;
int?    myYearLevel;
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
SupabaseClient get _db => Supabase.instance.client;

// ==================== MAIN ====================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  runApp(const MyApp());
}

// ==================== APP ====================
class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _db.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
          (_) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Smart School',
      theme: _buildTheme(),
      home: const SplashPage(),
    );
  }

  ThemeData _buildTheme() => ThemeData(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.navy, primary: AppColors.navy),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: AppColors.navy,
        statusBarIconBrightness: Brightness.light,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.navy, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greyLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.greyLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navy, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      color: Colors.white,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.gold,
      unselectedLabelColor: Colors.white60,
      indicatorColor: AppColors.gold,
      indicatorSize: TabBarIndicatorSize.label,
    ),
  );
}

// ==================== HELPERS ====================
Future<void> _loadProfile() async {
  currentUser = null;
  final userId = _db.auth.currentUser?.id;
  if (userId == null) return;
  for (int attempt = 0; attempt < 3; attempt++) {
    try {
      final profile = await _db
          .from('profiles')
          .select('id, email, full_name, role, class_id, year_level, is_active')
          .eq('id', userId)
          .single();
      currentUser = Map<String, dynamic>.from(profile);
      myClassId   = profile['class_id'] as String?;
      myYearLevel = profile['year_level'] as int?;
      if (myClassId != null) {
        try {
          final cls = await _db.from('classes').select().eq('id', myClassId!).single();
          myClassCode = cls['class_code'] as String?;
          myClassName = cls['name'] as String?;
        } catch (_) {}
      }
      return;
    } catch (e) {
      debugPrint('Load profile attempt ${attempt+1} error: $e');
      await Future.delayed(const Duration(milliseconds: 600));
    }
  }
}

Future<void> _logout(BuildContext context) async {
  await _db.auth.signOut();
  currentUser = null; myClassId = null; myClassCode = null; myClassName = null; myYearLevel = null;
  if (context.mounted) {
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SplashPage()), (_) => false);
  }
}

void _showSnack(BuildContext ctx, String msg, {bool isError = false}) {
  if (!ctx.mounted) return;
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Row(children: [
      Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 18),
      const SizedBox(width: 10),
      Expanded(child: Text(msg, style: const TextStyle(fontWeight: FontWeight.w500))),
    ]),
    backgroundColor: isError ? AppColors.red : AppColors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    margin: const EdgeInsets.all(16),
    duration: const Duration(seconds: 3),
  ));
}

String _fmtDate(dynamic raw) {
  if (raw == null) return '';
  try {
    final d = DateTime.parse(raw.toString()).toLocal();
    return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
  } catch (_) { return raw.toString(); }
}

List<Map<String, dynamic>> _toList(dynamic raw) => List<Map<String, dynamic>>.from(raw as List);

// ==================== SHARED WIDGETS ====================
class SchoolBanner extends StatelessWidget {
  final bool showLogo;
  final double topPadding;
  const SchoolBanner({super.key, this.showLogo = true, this.topPadding = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navy, AppColors.navyLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.only(
        top: topPadding + MediaQuery.of(context).padding.top,
        bottom: 24, left: 20, right: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(AppStrings.schoolName, style: const TextStyle(
                color: AppColors.gold, fontSize: 17, fontWeight: FontWeight.bold, height: 1.4,
              )),
              const SizedBox(height: 4),
              Text(AppStrings.churchName, style: TextStyle(color: Colors.white.withAlpha(210), fontSize: 13)),
              const SizedBox(height: 4),
              Text(AppStrings.motto, style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 11)),
            ]),
          ),
          if (showLogo) ...[
            const SizedBox(width: 12),
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2.5),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: ClipOval(
                child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.church, size: 36, color: AppColors.navy)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _chip(String label, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  decoration: BoxDecoration(
    color: color.withAlpha(30),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: color.withAlpha(80)),
  ),
  child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
);

Widget _statCard(String value, String label, Color color, IconData icon) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
        boxShadow: [BoxShadow(color: color.withAlpha(20), blurRadius: 8, offset: const Offset(0,2))],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: color.withAlpha(180))),
      ]),
    ),
  );
}

// ==================== SPLASH ====================
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    if (kIsWeb) {
      final params = Uri.base.queryParameters;
      final tokenHash = params['token_hash'];
      final type      = params['type'];
      final code      = params['code'];

      // token_hash flow — works across browsers and tabs
      if (tokenHash != null && tokenHash.isNotEmpty && type == 'recovery') {
        try {
          await _db.auth.verifyOTP(tokenHash: tokenHash, type: OtpType.recovery);
          debugPrint('OTP verified — going to reset page');
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
          }
          return;
        } catch (e) { debugPrint('OTP verify error: $e'); }
      }

      // PKCE code flow — fallback
      if (code != null && code.isNotEmpty) {
        try {
          await _db.auth.exchangeCodeForSession(code);
          await Future.delayed(const Duration(milliseconds: 400));
          debugPrint('Code exchanged — going to reset page');
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ResetPasswordPage()));
          }
          return;
        } catch (e) { debugPrint('Code exchange error: $e'); }
      }
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    final session = _db.auth.currentSession;
    if (session != null) {
      await _loadProfile();
      if (mounted) _navigate();
    } else {
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    }
  }

  void _navigate() {
    final role = currentUser?['role'] ?? 'student';
    final Widget page = role == 'super_admin' ? const SuperAdminPage()
        : role == 'admin' ? const AdminPage()
        : const StudentPage();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(children: [
          Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                color: Colors.white, shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 3),
                boxShadow: [BoxShadow(color: Colors.black.withAlpha(80), blurRadius: 24)],
              ),
              child: ClipOval(
                child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const Icon(Icons.church, size: 56, color: AppColors.navy)),
              ),
            ),
            const SizedBox(height: 32),
            const Text(AppStrings.schoolName, textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.gold, fontSize: 20, fontWeight: FontWeight.bold, height: 1.5)),
            const SizedBox(height: 8),
            Text(AppStrings.churchName, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14)),
            const SizedBox(height: 4),
            Text(AppStrings.motto, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 12)),
          ]))),
          const Padding(
            padding: EdgeInsets.only(bottom: 48),
            child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
          ),
        ]),
      ),
    );
  }
}

// ==================== LOGIN ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false, _obscure = true;
  String? _error;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) { setState(() => _error = 'Please fill all fields'); return; }
    setState(() { _loading = true; _error = null; });
    currentUser = null; myClassId = null; myClassCode = null; myClassName = null; myYearLevel = null;
    try {
      await _db.auth.signInWithPassword(email: email, password: pass);
      await Future.delayed(const Duration(milliseconds: 1000));
      await _loadProfile();
      if (!mounted) return;
      debugPrint('Role after login: ${currentUser?['role']}');
      final role = currentUser?['role'] ?? 'student';
      final Widget page = role == 'super_admin' ? const SuperAdminPage()
          : role == 'admin' ? const AdminPage() : const StudentPage();
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(children: [
        const SchoolBanner(topPadding: 30),
        Expanded(child: Container(
          decoration: const BoxDecoration(
            color: AppColors.bg,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 8),
              const Text('Welcome Back', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.navy)),
              const SizedBox(height: 4),
              const Text('Sign in to continue', style: TextStyle(color: AppColors.grey, fontSize: 15)),
              const SizedBox(height: 28),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.redBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.red.withAlpha(60)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w500))),
                  ]),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey))),
              const SizedBox(height: 16),
              TextFormField(controller: _passCtrl, obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  )),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ForgotPasswordPage())),
                  child: const Text('Forgot password?', style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 4),
              if (_loading)
                const Center(child: CircularProgressIndicator(color: AppColors.navy))
              else
                ElevatedButton(onPressed: _login,
                    child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignUpPage())),
                child: const Text('Create New Account', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
        )),
      ]),
    );
  }
}

// ==================== FORGOT PASSWORD ====================
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  bool _loading = false, _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_emailCtrl.text.trim().isEmpty) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Please enter your email', isError: true); return;
    }
    setState(() => _loading = true);
    try {
      final redirectUrl = kIsWeb ? '${Uri.base.origin}/' : 'io.supabase.smartschool://reset-callback/';
      await _db.auth.resetPasswordForEmail(_emailCtrl.text.trim(), redirectTo: redirectUrl);
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.navy,
    body: Column(children: [
      const SchoolBanner(topPadding: 20),
      Expanded(child: Container(
        decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _sent ? _sentView() : _formView()),
      )),
    ]),
  );

  Widget _formView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy)),
    const Text('Reset Password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
    const SizedBox(height: 8),
    const Text('Enter your email and we will send a reset link.', style: TextStyle(color: AppColors.grey)),
    const SizedBox(height: 32),
    TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey))),
    const SizedBox(height: 24),
    if (_loading)
      const Center(child: CircularProgressIndicator(color: AppColors.navy))
    else
      ElevatedButton(onPressed: _send, child: const Text('Send Reset Link', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
  ]);

  Widget _sentView() => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    const SizedBox(height: 60),
    Container(
      padding: const EdgeInsets.all(28),
      decoration: const BoxDecoration(color: AppColors.greenBg, shape: BoxShape.circle),
      child: const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.green),
    ),
    const SizedBox(height: 24),
    const Text('Email Sent!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
    const SizedBox(height: 12),
    Text('A reset link was sent to\n${_emailCtrl.text.trim()}\n\nOpen your email and tap the link.',
        textAlign: TextAlign.center, style: const TextStyle(color: AppColors.grey, height: 1.7)),
    const SizedBox(height: 32),
    ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login')),
  ]);
}

// ==================== RESET PASSWORD ====================
class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});
  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false, _obscure1 = true, _obscure2 = true, _done = false;

  @override
  void dispose() { _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _reset() async {
    final pass = _newCtrl.text.trim(), confirm = _confirmCtrl.text.trim();
    if (pass.isEmpty || confirm.isEmpty) { _showSnack(context, 'Please fill all fields', isError: true); return; }
    if (pass != confirm) { _showSnack(context, 'Passwords do not match', isError: true); return; }
    if (pass.length < 6) { _showSnack(context, 'Minimum 6 characters', isError: true); return; }
    setState(() => _loading = true);
    try {
      await _db.auth.updateUser(UserAttributes(password: pass));
      if (mounted) setState(() => _done = true);
      await Future.delayed(const Duration(milliseconds: 600));
      await _db.auth.signOut();
    } catch (e) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.navy,
    body: Column(children: [
      const SchoolBanner(topPadding: 20),
      Expanded(child: Container(
        decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _done ? _doneView() : _formView()),
      )),
    ]),
  );

  Widget _formView() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SizedBox(height: 8),
    const Text('Set New Password', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
    const SizedBox(height: 8),
    const Text('Enter your new password below.', style: TextStyle(color: AppColors.grey)),
    const SizedBox(height: 28),
    TextFormField(controller: _newCtrl, obscureText: _obscure1,
        decoration: InputDecoration(
          labelText: 'New Password', prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
          suffixIcon: IconButton(icon: Icon(_obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey),
              onPressed: () => setState(() => _obscure1 = !_obscure1)),
        )),
    const SizedBox(height: 16),
    TextFormField(controller: _confirmCtrl, obscureText: _obscure2,
        decoration: InputDecoration(
          labelText: 'Confirm Password', prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey),
          suffixIcon: IconButton(icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey),
              onPressed: () => setState(() => _obscure2 = !_obscure2)),
        )),
    const SizedBox(height: 24),
    if (_loading) const Center(child: CircularProgressIndicator(color: AppColors.navy))
    else ElevatedButton(onPressed: _reset, child: const Text('Save New Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
  ]);

  Widget _doneView() => Column(children: [
    const SizedBox(height: 60),
    Container(padding: const EdgeInsets.all(28), decoration: const BoxDecoration(color: AppColors.greenBg, shape: BoxShape.circle),
        child: const Icon(Icons.check_circle_outline, size: 64, color: AppColors.green)),
    const SizedBox(height: 24),
    const Text('Password Changed!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.navy)),
    const SizedBox(height: 12),
    const Text('Your password has been updated successfully.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
    const SizedBox(height: 32),
    ElevatedButton(
      onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (_) => false),
      child: const Text('Sign In'),
    ),
  ]);
}

// ==================== SIGN UP ====================
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl = TextEditingController(), _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController(), _confirmCtrl = TextEditingController();
  final _dobCtrl = TextEditingController(), _codeCtrl = TextEditingController();
  String _role = 'student';
  bool _loading = false, _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _confirmCtrl.dispose(); _dobCtrl.dispose(); _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(context: context, initialDate: DateTime(2005), firstDate: DateTime(1990), lastDate: DateTime.now());
    if (d != null) _dobCtrl.text = d.toIso8601String().split('T')[0];
  }

  Future<void> _signUp() async {
    final name = _nameCtrl.text.trim(), email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim(), confirm = _confirmCtrl.text.trim();
    final dob = _dobCtrl.text.trim(), code = _codeCtrl.text.trim().toUpperCase();
    if (name.isEmpty || email.isEmpty || pass.isEmpty || dob.isEmpty) { setState(() => _error = 'Please fill all required fields'); return; }
    if (pass != confirm) { setState(() => _error = 'Passwords do not match'); return; }
    if (pass.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }
    if (_role == 'student' && code.isEmpty) { setState(() => _error = 'Students must enter a class code'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _db.auth.signUp(email: email, password: pass);
      final userId = res.user?.id;
      if (userId == null) throw Exception('Failed to create account');
      String? classId; int? yearLevel;
      if (_role == 'student') {
        final cls = await _db.from('classes').select('id, year_level').eq('class_code', code).maybeSingle();
        if (cls == null) throw Exception('Invalid class code');
        classId = cls['id'].toString(); yearLevel = cls['year_level'] as int?;
      }
      await _db.from('profiles').insert({'id': userId, 'email': email, 'full_name': name, 'role': _role, 'date_of_birth': dob, 'class_id': classId, 'year_level': yearLevel, 'is_active': true});
      if (mounted) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Account created successfully!');
        Navigator.pop(context);
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.navy,
    body: Column(children: [
      const SchoolBanner(topPadding: 20, showLogo: false),
      Expanded(child: Container(
        decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28))),
        child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy)),
            const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
          ]),
          const SizedBox(height: 12),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.red.withAlpha(60))),
              child: Text(_error!, style: const TextStyle(color: AppColors.red, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline, color: AppColors.grey))),
          const SizedBox(height: 12),
          TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined, color: AppColors.grey))),
          const SizedBox(height: 12),
          TextFormField(controller: _passCtrl, obscureText: _obscure, decoration: InputDecoration(labelText: 'Password *', prefixIcon: const Icon(Icons.lock_outline, color: AppColors.grey), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: AppColors.grey), onPressed: () => setState(() => _obscure = !_obscure)))),
          const SizedBox(height: 12),
          TextFormField(controller: _confirmCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password *', prefixIcon: Icon(Icons.lock_outline, color: AppColors.grey))),
          const SizedBox(height: 12),
          TextFormField(controller: _dobCtrl, readOnly: true, onTap: _pickDate, decoration: const InputDecoration(labelText: 'Date of Birth *', prefixIcon: Icon(Icons.cake_outlined, color: AppColors.grey))),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.greyLight)),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _role, isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'student', child: Text('👦 Student')),
                  DropdownMenuItem(value: 'admin',   child: Text('👨‍🏫 Admin / Teacher')),
                ],
                onChanged: (v) => setState(() => _role = v!),
              ),
            ),
          ),
          if (_role == 'student') ...[
            const SizedBox(height: 12),
            TextFormField(controller: _codeCtrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Class Code *', prefixIcon: Icon(Icons.qr_code, color: AppColors.grey))),
          ],
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator(color: AppColors.navy))
          else
            ElevatedButton(onPressed: _signUp, child: const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          const SizedBox(height: 12),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Already have an account? Sign in', style: TextStyle(color: AppColors.navy))),
        ])),
      )),
    ]),
  );
}

// ==================== SUPER ADMIN PAGE ====================
class SuperAdminPage extends StatefulWidget {
  const SuperAdminPage({super.key});
  @override
  State<SuperAdminPage> createState() => _SuperAdminPageState();
}

class _SuperAdminPageState extends State<SuperAdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<List<Map<String, dynamic>>> _yearStudents = List.generate(5, (_) => <Map<String, dynamic>>[]);
  List<Map<String, dynamic>> _allAdmins = [], _allClasses = [];
  bool _loading = true;

  void _onTabChanged() { if (mounted) setState(() {}); }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAll();
  }

  @override
  void dispose() { _tabController.removeListener(_onTabChanged); _tabController.dispose(); super.dispose(); }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final raw = await _db.from('profiles').select().eq('role', 'student').order('full_name');
      final students = _toList(raw);
      final rawClasses2 = await _db.from('classes').select('id, year_level');
      final classYearMap = <String, int>{};
      for (final c in rawClasses2) { classYearMap[c['id'].toString()] = (c['year_level'] as int?) ?? 1; }
      for (int i = 0; i < 5; i++) {
        _yearStudents[i] = students.where((s) {
          final cid = s['class_id']?.toString();
          if (cid == null) return false;
          final yr = classYearMap[cid] ?? (s['year_level'] as int?);
          return yr == i + 1;
        }).toList();
      }
      final rawAdmins  = await _db.from('profiles').select().eq('role', 'admin');
      final rawClasses = await _db.from('classes').select().order('year_level');
      if (mounted) setState(() { _allAdmins = _toList(rawAdmins); _allClasses = _toList(rawClasses); });
    } catch (e) { debugPrint('SuperAdmin load: $e'); }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _promoteStudent(Map<String, dynamic> student) async {
    final current = (student['year_level'] as int?) ?? 1;
    if (current >= 5) { _showSnack(context, 'Student is already in the final year'); return; }
    final newYear = current + 1;
    final nextClasses = _allClasses.where((c) => (c['year_level'] as int?) == newYear).toList();
    if (nextClasses.isEmpty) { _showSnack(context, 'No class found for Year $newYear', isError: true); return; }
    String? selectedClassId = nextClasses.first['id'].toString();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Promote: ${student['full_name']}'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _chip('Year $current', AppColors.grey),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Icon(Icons.arrow_forward, color: AppColors.navy, size: 18)),
            _chip('Year $newYear', AppColors.green),
          ]),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedClassId,
            decoration: const InputDecoration(labelText: 'Select Class', border: OutlineInputBorder()),
            items: nextClasses.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? ''))).toList(),
            onChanged: (v) => set(() => selectedClassId = v),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Promote'),
          ),
        ],
      )),
    );
    if (confirm == true && mounted) {
      try {
        final sid = student['id'].toString();
        await _db.from('profiles').update({'year_level': newYear, 'class_id': selectedClassId}).eq('id', sid);
        await _db.from('grades').delete().eq('student_id', sid);
        await _db.from('attendance').delete().eq('student_id', sid);
        await _db.from('behavior_notes').delete().eq('student_id', sid);
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Student promoted to Year $newYear');
        _loadAll();
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _moveByEmail() async {
    final emailCtrl = TextEditingController();
    String? selectedClassId;
    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Move Student by Email'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Student Email', border: OutlineInputBorder())),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: selectedClassId,
            decoration: const InputDecoration(labelText: 'Target Class', border: OutlineInputBorder()),
            items: _allClasses.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text('${AppStrings.yearNames[((c['year_level'] as int?) ?? 1) - 1]} — ${c['name'] ?? ''}'))).toList(),
            onChanged: (v) => set(() => selectedClassId = v),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(minimumSize: const Size(0, 40)),
            onPressed: () async {
              if (emailCtrl.text.trim().isEmpty || selectedClassId == null) return;
              Navigator.pop(ctx);
              try {
                final cls = _allClasses.firstWhere((c) => c['id'].toString() == selectedClassId);
                final student = await _db.from('profiles').select('id').eq('email', emailCtrl.text.trim()).single();
                final sid = student['id'].toString();
                await _db.from('profiles').update({'class_id': selectedClassId, 'year_level': cls['year_level']}).eq('id', sid);
                await _db.from('grades').delete().eq('student_id', sid);
                await _db.from('attendance').delete().eq('student_id', sid);
                await _db.from('behavior_notes').delete().eq('student_id', sid);
                // ignore: use_build_context_synchronously
                _showSnack(context, 'Student moved successfully');
                _loadAll();
              } catch (e) {
                // ignore: use_build_context_synchronously
                _showSnack(context, 'Error: $e', isError: true);
              }
            },
            child: const Text('Move'),
          ),
        ],
      )),
    );
    emailCtrl.dispose();
  }

  Future<void> _removeStudent(Map<String, dynamic> student) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Remove Student'),
      content: Text('Remove ${student['full_name']} from school?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Remove')),
      ],
    ));
    if (confirm == true && mounted) {
      try {
        await _db.from('profiles').update({'is_active': false, 'class_id': null}).eq('id', student['id'].toString());
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Student removed');
        _loadAll();
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _deleteClass(Map<String, dynamic> cls) async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Class'),
      content: Text('Delete "${cls['name']}"? All data inside will be removed.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ));
    if (confirm == true && mounted) {
      try {
        await _db.from('classes').delete().eq('id', cls['id'].toString());
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Class deleted');
        _loadAll();
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _createClass() async {
    final nameCtrl = TextEditingController();
    int selectedYear = 1;
    String? selectedAdminId;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create New Class'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Class Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(initialValue: selectedYear, decoration: const InputDecoration(labelText: 'Year Level', border: OutlineInputBorder()), items: List.generate(5, (i) => DropdownMenuItem(value: i+1, child: Text(AppStrings.yearNames[i]))), onChanged: (v) => set(() => selectedYear = v!)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(initialValue: selectedAdminId, decoration: const InputDecoration(labelText: 'Assign Admin (optional)', border: OutlineInputBorder()), items: _allAdmins.map((a) => DropdownMenuItem(value: a['id'].toString(), child: Text(a['full_name'] ?? ''))).toList(), onChanged: (v) => set(() => selectedAdminId = v)),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
        ],
      )),
    );
    if (result == true && nameCtrl.text.isNotEmpty && mounted) {
      try {
        final rng = DateTime.now().microsecondsSinceEpoch;
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        final code = List.generate(6, (i) { final seed = (rng ~/ (i+1)) ^ (rng << (i*3)) ^ (i*104729); return chars[seed.abs() % chars.length]; }).join();
        final inserted = await _db.from('classes').insert({'name': nameCtrl.text.trim(), 'year_level': selectedYear, 'admin_id': selectedAdminId, 'class_code': code}).select().single();
        if (selectedAdminId != null) {
          // Admin can have multiple classes — just set class_id if they don't have one yet
          final adminProfile = await _db.from('profiles').select('class_id').eq('id', selectedAdminId!).single();
          if (adminProfile['class_id'] == null) {
            await _db.from('profiles').update({'class_id': inserted['id'], 'year_level': selectedYear}).eq('id', selectedAdminId!);
          }
        }
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Class created! Code: $code');
        _loadAll();
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
    nameCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
              : TabBarView(controller: _tabController, children: List.generate(5, (i) => _yearTab(i))),
        )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 0, left: 16, right: 16),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 2)),
            child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.church, color: AppColors.navy, size: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text(AppStrings.schoolName, style: TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.bold)),
            Text(currentUser?['full_name'] as String? ?? 'Super Admin', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 13, fontWeight: FontWeight.w500)),
          ])),
          _chip('SUPER ADMIN', AppColors.gold),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'email', child: Row(children: [Icon(Icons.swap_horiz, color: AppColors.blue), SizedBox(width: 10), Text('Move Student')])),
              PopupMenuItem(value: 'class', child: Row(children: [Icon(Icons.add_circle_outline, color: AppColors.green), SizedBox(width: 10), Text('Create Class')])),
              PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: AppColors.red), SizedBox(width: 10), Text('Sign Out', style: TextStyle(color: AppColors.red))])),
            ],
            onSelected: (String v) {
              if (v == 'email')  _moveByEmail();
              if (v == 'class')  _createClass();
              if (v == 'logout') _logout(context);
            },
          ),
        ]),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: List.generate(5, (i) => Tab(text: AppStrings.yearNames[i])),
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ]),
    );
  }

  Widget _yearTab(int yearIndex) {
    final students    = _yearStudents[yearIndex];
    final yearClasses = _allClasses.where((c) => (c['year_level'] as int?) == yearIndex + 1).toList();
    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(padding: const EdgeInsets.all(16), children: [
        if (yearClasses.isNotEmpty) ...[
          Container(
            decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.gold.withAlpha(80))),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.gold.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.qr_code_2, color: AppColors.navy, size: 18)),
                const SizedBox(width: 10),
                const Text('Class Codes', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy, fontSize: 15)),
              ]),
              const SizedBox(height: 12),
              ...yearClasses.map((c) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Expanded(child: Text(c['name'] ?? '', style: const TextStyle(color: AppColors.navy, fontWeight: FontWeight.w500))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(10)),
                    child: Text(c['class_code'] ?? '', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 16, letterSpacing: 2)),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => _deleteClass(c),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.delete_outline, color: AppColors.red, size: 18)),
                  ),
                ]),
              )),
            ]),
          ),
          const SizedBox(height: 16),
        ],
        Row(children: [
          Text(AppStrings.yearNames[yearIndex], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
            child: Text('${students.length}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ]),
        const SizedBox(height: 10),
        if (students.isEmpty)
          Container(
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: Column(children: [
              Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.greyLight.withAlpha(80), shape: BoxShape.circle),
                  child: Icon(Icons.people_outline, size: 48, color: Colors.grey.shade400)),
              const SizedBox(height: 12),
              Text('No students in ${AppStrings.yearNames[yearIndex]}', style: const TextStyle(color: AppColors.grey)),
            ]),
          )
        else
          ...students.map((s) => _studentCard(s)),
      ]),
    );
  }

  Widget _studentCard(Map<String, dynamic> s) {
    final name = s['full_name'] as String? ?? '?';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: AppColors.navyLight,
          radius: 22,
          child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        subtitle: Text(s['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
        trailing: PopupMenuButton<String>(
          icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.more_vert, color: AppColors.grey, size: 20)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'promote', child: Row(children: [Icon(Icons.trending_up, color: AppColors.green, size: 18), SizedBox(width: 10), Text('Promote to Next Year')])),
            PopupMenuItem(value: 'remove',  child: Row(children: [Icon(Icons.remove_circle_outline, color: AppColors.red, size: 18), SizedBox(width: 10), Text('Remove', style: TextStyle(color: AppColors.red))])),
          ],
          onSelected: (String v) {
            if (v == 'promote') _promoteStudent(s);
            if (v == 'remove')  _removeStudent(s);
          },
        ),
      ),
    );
  }
}

// ==================== ADMIN PAGE (MULTI-CLASS) ====================
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Multiple classes support
  List<Map<String, dynamic>> _myClasses = [];
  int _selectedClassIndex = 0;
  List<Map<String, dynamic>> _students = [], _lessons = [];
  bool _loading = true;

  void _onTabChanged() { if (mounted) setState(() {}); }

  Map<String, dynamic>? get _currentClass => _myClasses.isEmpty ? null : _myClasses[_selectedClassIndex];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() { _tabController.removeListener(_onTabChanged); _tabController.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      // Load ALL classes for this admin
      final rawClasses = await _db.from('classes').select().eq('admin_id', currentUser!['id'].toString()).order('year_level');
      _myClasses = _toList(rawClasses);
      if (_selectedClassIndex >= _myClasses.length) _selectedClassIndex = 0;
      if (_myClasses.isNotEmpty) {
        final cls = _myClasses[_selectedClassIndex];
        myClassId   = cls['id'].toString();
        myClassCode = cls['class_code'] as String?;
        myClassName = cls['name'] as String?;
        final rawS = await _db.from('profiles').select().eq('class_id', myClassId!).eq('role', 'student').order('full_name');
        final rawL = await _db.from('lessons').select().eq('class_id', myClassId!).order('created_at', ascending: false);
        if (mounted) setState(() { _students = _toList(rawS); _lessons = _toList(rawL); });
      }
    } catch (e) { debugPrint('Admin load: $e'); }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _switchClass(int index) async {
    if (index == _selectedClassIndex) return;
    _selectedClassIndex = index;
    await _loadData();
  }

  Future<void> _addLesson() async {
    final titleCtrl = TextEditingController(), contentCtrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add New Lesson'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Lesson Title', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: contentCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Lesson Content', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
      ],
    ));
    final titleText = titleCtrl.text.trim(), contentText = contentCtrl.text.trim();
    titleCtrl.dispose(); contentCtrl.dispose();
    if (ok == true && titleText.isNotEmpty && mounted) {
      try {
        await _db.from('lessons').insert({'class_id': myClassId, 'title': titleText, 'content': contentText});
        _loadData();
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Lesson added');
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _deleteLesson(String id) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Delete Lesson'),
      content: const Text('Are you sure?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
      ],
    ));
    if (ok == true && mounted) { await _db.from('lessons').delete().eq('id', id); _loadData(); _showSnack(context, 'Lesson deleted'); }
  }

  Future<void> _addGrade(Map<String, dynamic> student) async {
    final gradeCtrl = TextEditingController(), notesCtrl = TextEditingController();
    String gradeType = 'quiz';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Add Grade — ${student['full_name']}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: gradeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Grade (0-100)', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: gradeType, decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
          items: const [DropdownMenuItem(value: 'quiz', child: Text('📝 Quiz')), DropdownMenuItem(value: 'exam', child: Text('📋 Exam')), DropdownMenuItem(value: 'homework', child: Text('📚 Homework'))],
          onChanged: (v) => set(() => gradeType = v!)),
        const SizedBox(height: 12),
        TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    )));
    final gradeText = gradeCtrl.text.trim(), notesText = notesCtrl.text.trim();
    gradeCtrl.dispose(); notesCtrl.dispose();
    if (ok == true && gradeText.isNotEmpty && mounted) {
      try {
        await _db.from('grades').insert({'student_id': student['id'].toString(), 'class_id': myClassId, 'grade_value': double.parse(gradeText), 'grade_type': gradeType, 'notes': notesText});
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Grade added');
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _markAttendance(Map<String, dynamic> student) async {
    String status = 'present';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Attendance — ${student['full_name']}'),
      content: DropdownButtonFormField<String>(
        initialValue: status,
        decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
        items: const [DropdownMenuItem(value: 'present', child: Text('✅ Present')), DropdownMenuItem(value: 'absent', child: Text('❌ Absent')), DropdownMenuItem(value: 'late', child: Text('⏰ Late'))],
        onChanged: (v) => set(() => status = v!),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    )));
    if (ok == true && mounted) {
      try {
        await _db.from('attendance').insert({'student_id': student['id'].toString(), 'class_id': myClassId, 'status': status, 'attendance_date': DateTime.now().toIso8601String().split('T')[0]});
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Attendance recorded');
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _addBehavior(Map<String, dynamic> student) async {
    final descCtrl = TextEditingController();
    String noteType = 'positive';
    final ok = await showDialog<bool>(context: context, builder: (ctx) => StatefulBuilder(builder: (ctx, set) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Behavior Note — ${student['full_name']}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        DropdownButtonFormField<String>(initialValue: noteType, decoration: const InputDecoration(labelText: 'Note Type', border: OutlineInputBorder()),
          items: const [DropdownMenuItem(value: 'positive', child: Text('🌟 Positive')), DropdownMenuItem(value: 'warning', child: Text('⚠️ Warning')), DropdownMenuItem(value: 'negative', child: Text('❌ Negative'))],
          onChanged: (v) => set(() => noteType = v!)),
        const SizedBox(height: 12),
        TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
      ],
    )));
    final descText = descCtrl.text.trim();
    descCtrl.dispose();
    if (ok == true && descText.isNotEmpty && mounted) {
      try {
        await _db.from('behavior_notes').insert({'student_id': student['id'].toString(), 'admin_id': currentUser!['id'].toString(), 'note_type': noteType, 'description': descText});
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Note added');
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Widget _quickBtn(String emoji, Color color, VoidCallback onTap) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(10),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withAlpha(60))),
      child: Text(emoji, style: const TextStyle(fontSize: 18)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
              : _myClasses.isEmpty
                  ? _noClassView()
                  : Column(children: [
                      if (_myClasses.length > 1) _classSelector(),
                      Expanded(child: TabBarView(controller: _tabController, children: [_lessonsTab(), _studentsTab(), _dailyTab()])),
                    ]),
        )),
      ]),
      floatingActionButton: _myClasses.isNotEmpty && !_tabController.indexIsChanging && _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _addLesson,
              backgroundColor: AppColors.navy,
              icon: const Icon(Icons.add),
              label: const Text('New Lesson', style: TextStyle(fontWeight: FontWeight.w600)),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 0, left: 16, right: 16),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 2)),
            child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.church, color: AppColors.navy, size: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_currentClass?['name'] as String? ?? 'My Classes', style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                child: const Text('ADMIN', style: TextStyle(color: AppColors.navy, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 6),
              Flexible(child: Text(currentUser?['full_name'] as String? ?? '', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11), overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          if (_currentClass?['class_code'] != null)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(border: Border.all(color: AppColors.gold), borderRadius: BorderRadius.circular(8)),
              child: Text(_currentClass!['class_code'] as String, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 13, letterSpacing: 1)),
            ),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: () => _logout(context)),
        ]),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Lessons'), Tab(text: 'Students'), Tab(text: 'Daily Attendance')],
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  Widget _classSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Select Class', style: TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: List.generate(_myClasses.length, (i) {
            final cls = _myClasses[i];
            final selected = i == _selectedClassIndex;
            return GestureDetector(
              onTap: () => _switchClass(i),
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.navy : AppColors.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: selected ? AppColors.navy : AppColors.greyLight),
                ),
                child: Row(children: [
                  Text(cls['name'] ?? '', style: TextStyle(color: selected ? Colors.white : AppColors.navy, fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: selected ? AppColors.gold : AppColors.greyLight, borderRadius: BorderRadius.circular(10)),
                    child: Text(AppStrings.yearNames[(((cls['year_level'] as int?) ?? 1) - 1).clamp(0, 4)], style: TextStyle(color: selected ? AppColors.navy : AppColors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ]),
              ),
            );
          })),
        ),
      ]),
    );
  }

  Widget _noClassView() {
    return Center(child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.orangeBg, shape: BoxShape.circle),
            child: const Icon(Icons.class_outlined, size: 56, color: AppColors.orange)),
        const SizedBox(height: 24),
        const Text('No Classes Assigned', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
        const SizedBox(height: 8),
        const Text('Contact the Super Admin to assign you to a class.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey, height: 1.5)),
      ]),
    ));
  }

  Widget _lessonsTab() {
    if (_lessons.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.blueBg, shape: BoxShape.circle), child: const Icon(Icons.menu_book_outlined, size: 48, color: AppColors.blue)),
        const SizedBox(height: 16),
        const Text('No lessons yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
        const SizedBox(height: 4),
        const Text('Tap + to add the first lesson', style: TextStyle(color: AppColors.grey)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (_, i) {
        final l = _lessons[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.navyLight, borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text('${i+1}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold))),
            ),
            title: Text(l['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
            subtitle: Text(l['content'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.grey, fontSize: 13)),
            trailing: IconButton(
              icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.redBg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline, color: AppColors.red, size: 16)),
              onPressed: () => _deleteLesson(l['id'].toString()),
            ),
            onTap: () => _showLessonSheet(context, l),
          ),
        );
      },
    );
  }

  void _showLessonSheet(BuildContext context, Map<String, dynamic> l) {
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (ctx) => DraggableScrollableSheet(expand: false, initialChildSize: 0.6, maxChildSize: 0.9, builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.greyLight, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(l['title'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const Divider(height: 24),
            Expanded(child: SingleChildScrollView(controller: ctrl, child: Text(l['content'] ?? '', style: const TextStyle(height: 1.8, fontSize: 15, color: AppColors.navy)))),
          ]),
        )));
  }

  Widget _studentsTab() {
    if (_students.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.purpleBg, shape: BoxShape.circle), child: const Icon(Icons.people_outline, size: 48, color: AppColors.purple)),
        const SizedBox(height: 16),
        const Text('No students yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
        const SizedBox(height: 4),
        Text('Class code: ${myClassCode ?? ''}', style: const TextStyle(color: AppColors.grey)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (_, i) {
        final s = _students[i];
        final name = s['full_name'] as String? ?? '?';
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            leading: CircleAvatar(backgroundColor: AppColors.navyLight, radius: 22, child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16))),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
            subtitle: Text(s['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            trailing: PopupMenuButton<String>(
              icon: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.more_vert, color: AppColors.grey, size: 20)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'view',     child: Row(children: [Icon(Icons.visibility_outlined, size: 18, color: AppColors.blue), SizedBox(width: 10), Text('View Details')])),
                PopupMenuItem(value: 'grade',    child: Row(children: [Icon(Icons.grade_outlined, size: 18, color: AppColors.orange), SizedBox(width: 10), Text('Add Grade')])),
                PopupMenuItem(value: 'attend',   child: Row(children: [Icon(Icons.how_to_reg_outlined, size: 18, color: AppColors.green), SizedBox(width: 10), Text('Record Attendance')])),
                PopupMenuItem(value: 'behavior', child: Row(children: [Icon(Icons.psychology_outlined, size: 18, color: AppColors.purple), SizedBox(width: 10), Text('Behavior Note')])),
              ],
              onSelected: (String v) {
                if (v == 'view') {
                  // ignore: use_build_context_synchronously
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailPage(student: s)));
                } else if (v == 'grade')    { _addGrade(s); }
                  else if (v == 'attend')   { _markAttendance(s); }
                  else if (v == 'behavior') { _addBehavior(s); }
              },
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailPage(student: s))),
          ),
        );
      },
    );
  }

  Widget _dailyTab() {
    if (_students.isEmpty) return const Center(child: Text('No students found.', style: TextStyle(color: AppColors.grey)));
    final today = DateTime.now().toIso8601String().split('T')[0];
    return Column(children: [
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.goldLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.gold.withAlpha(100))),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: AppColors.gold.withAlpha(30), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.calendar_today, color: AppColors.navy, size: 16)),
          const SizedBox(width: 10),
          Text("Today's Attendance — $today", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _students.length,
        itemBuilder: (_, i) {
          final s = _students[i];
          final name = s['full_name'] as String? ?? '?';
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: ListTile(
              leading: CircleAvatar(backgroundColor: AppColors.navyLight, radius: 20, child: Text(name.isNotEmpty ? name[0] : '?', style: const TextStyle(color: AppColors.gold, fontSize: 14))),
              title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                _quickBtn('✅', AppColors.green, () async { try { await _db.from('attendance').insert({'student_id': s['id'].toString(), 'class_id': myClassId, 'status': 'present', 'attendance_date': today}); _showSnack(context, '$name: Present'); } catch (e) { _showSnack(context, 'Error: $e', isError: true); } }),
                _quickBtn('❌', AppColors.red,   () async { try { await _db.from('attendance').insert({'student_id': s['id'].toString(), 'class_id': myClassId, 'status': 'absent',  'attendance_date': today}); _showSnack(context, '$name: Absent', isError: true); } catch (e) { _showSnack(context, 'Error: $e', isError: true); } }),
                _quickBtn('⏰', AppColors.orange, () async { try { await _db.from('attendance').insert({'student_id': s['id'].toString(), 'class_id': myClassId, 'status': 'late',    'attendance_date': today}); _showSnack(context, '$name: Late'); } catch (e) { _showSnack(context, 'Error: $e', isError: true); } }),
              ]),
            ),
          );
        },
      )),
    ]);
  }
}

// ==================== STUDENT DETAIL PAGE ====================
class StudentDetailPage extends StatefulWidget {
  final Map<String, dynamic> student;
  const StudentDetailPage({super.key, required this.student});
  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _grades = [], _attendance = [], _behavior = [];
  bool _loading = true;

  void _onTabChanged() { if (mounted) setState(() {}); }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
  }

  @override
  void dispose() { _tabController.removeListener(_onTabChanged); _tabController.dispose(); super.dispose(); }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final sid = widget.student['id'].toString();
      final rawG = await _db.from('grades').select().eq('student_id', sid).order('created_at', ascending: false);
      final rawA = await _db.from('attendance').select().eq('student_id', sid).order('attendance_date', ascending: false);
      final rawB = await _db.from('behavior_notes').select().eq('student_id', sid).order('created_at', ascending: false);
      if (mounted) setState(() { _grades = _toList(rawG); _attendance = _toList(rawA); _behavior = _toList(rawB); });
    } catch (e) { debugPrint('StudentDetail: $e'); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      title: Text(widget.student['full_name'] as String? ?? ''),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [Tab(text: 'Grades'), Tab(text: 'Attendance'), Tab(text: 'Behavior')],
        indicatorColor: AppColors.gold,
        labelColor: AppColors.gold,
        unselectedLabelColor: Colors.white54,
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
        : TabBarView(controller: _tabController, children: [_gradesTab(), _attendanceTab(), _behaviorTab()]),
  );

  Widget _gradesTab() {
    if (_grades.isEmpty) return const Center(child: Text('No grades yet.', style: TextStyle(color: AppColors.grey)));
    final avg = _grades.map((g) => (g['grade_value'] as num? ?? 0).toDouble()).reduce((a, b) => a + b) / _grades.length;
    const tMap = {'quiz': '📝 Quiz', 'exam': '📋 Exam', 'homework': '📚 Homework'};
    return Column(children: [
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.gold.withAlpha(40), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.bar_chart, color: AppColors.gold, size: 32)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Overall Average', style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 13)),
            Text(avg.toStringAsFixed(1), style: const TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _grades.length,
        itemBuilder: (_, i) {
          final g = _grades[i]; final v = (g['grade_value'] as num? ?? 0).toDouble(); final ok = v >= 50;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ok ? AppColors.green.withAlpha(60) : AppColors.red.withAlpha(60))),
            child: ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: ok ? AppColors.greenBg : AppColors.redBg, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(v.toStringAsFixed(0), style: TextStyle(color: ok ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold, fontSize: 14)))),
              title: Text(tMap[g['grade_type'] as String? ?? 'quiz'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
              subtitle: (g['notes'] as String? ?? '').isNotEmpty ? Text(g['notes'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 12)) : null,
              trailing: Text(_fmtDate(g['created_at']), style: const TextStyle(color: AppColors.grey, fontSize: 11)),
            ),
          );
        },
      )),
    ]);
  }

  Widget _attendanceTab() {
    final present = _attendance.where((a) => a['status'] == 'present').length;
    final absent  = _attendance.where((a) => a['status'] == 'absent').length;
    final late    = _attendance.where((a) => a['status'] == 'late').length;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _statCard('$present', 'Present', AppColors.green,  Icons.check_circle_outline),
          const SizedBox(width: 10),
          _statCard('$absent',  'Absent',  AppColors.red,    Icons.cancel_outlined),
          const SizedBox(width: 10),
          _statCard('$late',    'Late',    AppColors.orange, Icons.schedule_outlined),
        ]),
      ),
      Expanded(child: _attendance.isEmpty
          ? const Center(child: Text('No attendance records.', style: TextStyle(color: AppColors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _attendance.length,
              itemBuilder: (_, i) {
                final a = _attendance[i]; final key = a['status'] as String? ?? 'present';
                final info = {'present': ('✅ Present', AppColors.green), 'absent': ('❌ Absent', AppColors.red), 'late': ('⏰ Late', AppColors.orange)}[key] ?? ('? Unknown', AppColors.grey);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListTile(dense: true, leading: Text(info.$1.split(' ')[0], style: const TextStyle(fontSize: 22)), title: Text(info.$1, style: TextStyle(color: info.$2, fontWeight: FontWeight.w600)), trailing: Text(a['attendance_date'] as String? ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 12))),
                );
              },
            )),
    ]);
  }

  Widget _behaviorTab() {
    final pos = _behavior.where((b) => b['note_type'] == 'positive').length;
    final war = _behavior.where((b) => b['note_type'] == 'warning').length;
    final neg = _behavior.where((b) => b['note_type'] == 'negative').length;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _statCard('$pos', 'Positive', AppColors.green,  Icons.star_outline),
          const SizedBox(width: 10),
          _statCard('$war', 'Warning',  AppColors.orange, Icons.warning_amber_outlined),
          const SizedBox(width: 10),
          _statCard('$neg', 'Negative', AppColors.red,    Icons.thumb_down_outlined),
        ]),
      ),
      Expanded(child: _behavior.isEmpty
          ? const Center(child: Text('No behavior notes.', style: TextStyle(color: AppColors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _behavior.length,
              itemBuilder: (_, i) {
                final b = _behavior[i]; final key = b['note_type'] as String? ?? 'positive';
                final info = {'positive': ('🌟 Positive', AppColors.green), 'warning': ('⚠️ Warning', AppColors.orange), 'negative': ('❌ Negative', AppColors.red)}[key] ?? ('? Unknown', AppColors.grey);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: info.$2.withAlpha(60))),
                  child: Container(
                    decoration: BoxDecoration(border: Border(left: BorderSide(color: info.$2, width: 4)), borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Text(info.$1, style: TextStyle(fontWeight: FontWeight.bold, color: info.$2, fontSize: 13)), const Spacer(), Text(_fmtDate(b['created_at']), style: const TextStyle(color: AppColors.grey, fontSize: 11))]),
                      const SizedBox(height: 6),
                      Text(b['description'] as String? ?? '', style: const TextStyle(height: 1.5, color: AppColors.navy)),
                    ]),
                  ),
                );
              },
            )),
    ]);
  }
}

// ==================== STUDENT PAGE ====================
class StudentPage extends StatefulWidget {
  const StudentPage({super.key});
  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _lessons = [], _grades = [], _attendance = [], _behavior = [];
  bool _loading = true;

  void _onTabChanged() { if (mounted) setState(() {}); }

  @override
  void initState() { super.initState(); _tabController = TabController(length: 4, vsync: this); _tabController.addListener(_onTabChanged); _loadData(); }

  @override
  void dispose() { _tabController.removeListener(_onTabChanged); _tabController.dispose(); super.dispose(); }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      if (myClassId != null) {
        final sid = currentUser!['id'].toString();
        final rawL = await _db.from('lessons').select().eq('class_id', myClassId!).order('created_at', ascending: false);
        final rawG = await _db.from('grades').select().eq('student_id', sid).order('created_at', ascending: false);
        final rawA = await _db.from('attendance').select().eq('student_id', sid).eq('class_id', myClassId!).order('attendance_date', ascending: false);
        final rawB = await _db.from('behavior_notes').select().eq('student_id', sid).order('created_at', ascending: false);
        if (mounted) setState(() { _lessons = _toList(rawL); _grades = _toList(rawG); _attendance = _toList(rawA); _behavior = _toList(rawB); });
      }
    } catch (e) { debugPrint('Student load: $e'); }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _joinClass() async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Join a Class'),
      content: TextField(controller: ctrl, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'Class Code', border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code))),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(style: ElevatedButton.styleFrom(minimumSize: const Size(0,40)), onPressed: () => Navigator.pop(ctx, true), child: const Text('Join')),
      ],
    ));
    final codeText = ctrl.text.trim().toUpperCase();
    ctrl.dispose();
    if (ok == true && codeText.isNotEmpty && mounted) {
      try {
        final cls = await _db.from('classes').select().eq('class_code', codeText).maybeSingle();
        if (cls != null) {
          await _db.from('profiles').update({'class_id': cls['id'].toString(), 'year_level': cls['year_level']}).eq('id', currentUser!['id'].toString());
          currentUser!['class_id'] = cls['id'];
          myClassId = cls['id'].toString(); myClassCode = cls['class_code'] as String?; myClassName = cls['name'] as String?;
          _loadData();
          // ignore: use_build_context_synchronously
          _showSnack(context, 'Joined class successfully!');
        } else {
          // ignore: use_build_context_synchronously
          _showSnack(context, 'Invalid class code', isError: true);
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        _showSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  String _yearLabel() { final y = currentUser?['year_level'] as int?; if (y == null || y < 1 || y > 5) return ''; return AppStrings.yearNames[y - 1]; }

  @override
  Widget build(BuildContext context) {
    final role = currentUser?['role'] as String? ?? 'student';
    if (role == 'super_admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ignore: use_build_context_synchronously
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SuperAdminPage()));
      });
    } else if (role == 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ignore: use_build_context_synchronously
        if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminPage()));
      });
    }

    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(children: [
        _buildHeader(),
        Expanded(child: Container(
          decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
          child: _loading
              ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
              : myClassId == null
                  ? _noClassView()
                  : TabBarView(controller: _tabController, children: [_lessonsTab(), _gradesTab(), _attendanceTab(), _behaviorTab()]),
        )),
      ]),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.navy,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, bottom: 0, left: 16, right: 16),
      child: Column(children: [
        Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppColors.gold, width: 2)),
            child: ClipOval(child: Image.asset('assets/logo.png', fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.church, color: AppColors.navy, size: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(currentUser?['full_name'] as String? ?? '', style: const TextStyle(color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.bold)),
            Text(myClassName != null ? '$myClassName • ${_yearLabel()}' : AppStrings.schoolName, style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 11)),
          ])),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white70), onPressed: () => _logout(context)),
        ]),
        const SizedBox(height: 12),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [Tab(text: 'Lessons'), Tab(text: 'Grades'), Tab(text: 'Attendance'), Tab(text: 'Behavior')],
          indicatorColor: AppColors.gold,
          labelColor: AppColors.gold,
          unselectedLabelColor: Colors.white54,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ]),
    );
  }

  Widget _noClassView() => Center(child: Padding(
    padding: const EdgeInsets.all(32),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: AppColors.blueBg, shape: BoxShape.circle), child: const Icon(Icons.class_outlined, size: 56, color: AppColors.blue)),
      const SizedBox(height: 24),
      const Text('Not enrolled yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
      const SizedBox(height: 8),
      const Text('Enter your class code to join.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: _joinClass, icon: const Icon(Icons.add), label: const Text('Join a Class', style: TextStyle(fontWeight: FontWeight.bold))),
    ]),
  ));

  Widget _lessonsTab() {
    if (_lessons.isEmpty) return const Center(child: Text('No lessons yet.', style: TextStyle(color: AppColors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (_, i) {
        final l = _lessons[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: ExpansionTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppColors.navyLight, borderRadius: BorderRadius.circular(10)), child: Center(child: Text('${i+1}', style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)))),
            title: Text(l['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
            children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Text(l['content'] ?? '', style: const TextStyle(height: 1.8, color: AppColors.navy)))],
          ),
        );
      },
    );
  }

  Widget _gradesTab() {
    if (_grades.isEmpty) return const Center(child: Text('No grades yet.', style: TextStyle(color: AppColors.grey)));
    final avg = _grades.map((g) => (g['grade_value'] as num? ?? 0).toDouble()).reduce((a, b) => a + b) / _grades.length;
    const tMap = {'quiz': '📝 Quiz', 'exam': '📋 Exam', 'homework': '📚 Homework'};
    return Column(children: [
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.gold.withAlpha(40), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.bar_chart, color: AppColors.gold, size: 32)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Overall Average', style: TextStyle(color: Colors.white.withAlpha(190), fontSize: 13)),
            Text(avg.toStringAsFixed(1), style: const TextStyle(color: AppColors.gold, fontSize: 32, fontWeight: FontWeight.bold)),
          ]),
        ]),
      ),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _grades.length,
        itemBuilder: (_, i) {
          final g = _grades[i]; final v = (g['grade_value'] as num? ?? 0).toDouble(); final ok = v >= 50;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ok ? AppColors.green.withAlpha(60) : AppColors.red.withAlpha(60))),
            child: ListTile(
              leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: ok ? AppColors.greenBg : AppColors.redBg, borderRadius: BorderRadius.circular(12)), child: Center(child: Text(v.toStringAsFixed(0), style: TextStyle(color: ok ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold, fontSize: 14)))),
              title: Text(tMap[g['grade_type'] as String? ?? 'quiz'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
              subtitle: (g['notes'] as String? ?? '').isNotEmpty ? Text(g['notes'] as String, style: const TextStyle(color: AppColors.grey, fontSize: 12)) : null,
              trailing: Text(_fmtDate(g['created_at']), style: const TextStyle(fontSize: 11, color: AppColors.grey)),
            ),
          );
        },
      )),
    ]);
  }

  Widget _attendanceTab() {
    final present = _attendance.where((a) => a['status'] == 'present').length;
    final absent  = _attendance.where((a) => a['status'] == 'absent').length;
    final late    = _attendance.where((a) => a['status'] == 'late').length;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _statCard('$present', 'Present', AppColors.green,  Icons.check_circle_outline),
          const SizedBox(width: 10),
          _statCard('$absent',  'Absent',  AppColors.red,    Icons.cancel_outlined),
          const SizedBox(width: 10),
          _statCard('$late',    'Late',    AppColors.orange, Icons.schedule_outlined),
        ]),
      ),
      Expanded(child: _attendance.isEmpty
          ? const Center(child: Text('No attendance records.', style: TextStyle(color: AppColors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _attendance.length,
              itemBuilder: (_, i) {
                final a = _attendance[i]; final key = a['status'] as String? ?? 'present';
                final info = {'present': ('✅ Present', AppColors.green), 'absent': ('❌ Absent', AppColors.red), 'late': ('⏰ Late', AppColors.orange)}[key] ?? ('? Unknown', AppColors.grey);
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: ListTile(dense: true, leading: Text(info.$1.split(' ')[0], style: const TextStyle(fontSize: 22)), title: Text(info.$1, style: TextStyle(color: info.$2, fontWeight: FontWeight.w600)), trailing: Text(a['attendance_date'] as String? ?? '', style: const TextStyle(color: AppColors.grey, fontSize: 12))),
                );
              },
            )),
    ]);
  }

  Widget _behaviorTab() {
    final pos = _behavior.where((b) => b['note_type'] == 'positive').length;
    final war = _behavior.where((b) => b['note_type'] == 'warning').length;
    final neg = _behavior.where((b) => b['note_type'] == 'negative').length;
    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          _statCard('$pos', 'Positive', AppColors.green,  Icons.star_outline),
          const SizedBox(width: 10),
          _statCard('$war', 'Warning',  AppColors.orange, Icons.warning_amber_outlined),
          const SizedBox(width: 10),
          _statCard('$neg', 'Negative', AppColors.red,    Icons.thumb_down_outlined),
        ]),
      ),
      Expanded(child: _behavior.isEmpty
          ? const Center(child: Text('No behavior notes.', style: TextStyle(color: AppColors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _behavior.length,
              itemBuilder: (_, i) {
                final b = _behavior[i]; final key = b['note_type'] as String? ?? 'positive';
                final info = {'positive': ('🌟 Positive', AppColors.green), 'warning': ('⚠️ Warning', AppColors.orange), 'negative': ('❌ Negative', AppColors.red)}[key] ?? ('? Unknown', AppColors.grey);
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: info.$2.withAlpha(60))),
                  child: Container(
                    decoration: BoxDecoration(border: Border(left: BorderSide(color: info.$2, width: 4)), borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.all(14),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Text(info.$1, style: TextStyle(fontWeight: FontWeight.bold, color: info.$2, fontSize: 13)), const Spacer(), Text(_fmtDate(b['created_at']), style: const TextStyle(color: AppColors.grey, fontSize: 11))]),
                      const SizedBox(height: 6),
                      Text(b['description'] as String? ?? '', style: const TextStyle(height: 1.5, color: AppColors.navy)),
                    ]),
                  ),
                );
              },
            )),
    ]);
  }
}