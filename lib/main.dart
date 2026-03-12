// ============================================================
//  Smart School App — Flutter  (fixed)
//  pubspec.yaml dependencies:
//    supabase_flutter: ^2.5.0
//    app_links: ^6.1.1
//  assets:
//    - assets/logo.png
//
//  Android AndroidManifest.xml inside <activity>:
//    <intent-filter android:autoVerify="true">
//      <action android:name="android.intent.action.VIEW"/>
//      <category android:name="android.intent.category.DEFAULT"/>
//      <category android:name="android.intent.category.BROWSABLE"/>
//      <data android:scheme="io.supabase.smartschool"
//            android:host="reset-callback"/>
//    </intent-filter>
//
//  Supabase → Auth → URL Configuration:
//    Site URL      : io.supabase.smartschool://reset-callback/
//    Redirect URLs : io.supabase.smartschool://reset-callback/
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ==================== COLORS ====================
class AppColors {
  static const Color navy      = Color(0xFF1A2E4A);
  static const Color navyLight = Color(0xFF243B55);
  static const Color gold      = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFFFF8E1);
  static const Color bg        = Color(0xFFF0F4F8);
  static const Color green     = Color(0xFF2E7D32);
  static const Color greenBg   = Color(0xFFE8F5E9);
  static const Color red       = Color(0xFFC62828);
  static const Color redBg     = Color(0xFFFFEBEE);
  static const Color orange    = Color(0xFFE65100);
  static const Color grey      = Color(0xFF607D8B);
  static const Color blue      = Color(0xFF0D47A1);
}

// ==================== STRINGS ====================
class AppStrings {
  // *** Arabic only — do NOT translate ***
  static const String schoolName = 'مدرسة الطغمات السمائية للشمامسة';
  static const String churchName = 'كنيسة العذراء مريم والسمائين';
  static const String motto      = 'مدرسة تهدف لتعليم الألحان والطقوس الكنسية';

  static const List<String> yearNames = [
    'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5',
  ];
}

// ==================== GLOBAL STATE ====================
Map<String, dynamic>? currentUser;
String? myClassId;
String? myClassCode;
String? myClassName;
int?    myYearLevel;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// FIX: top-level getter instead of global variable to avoid late-init issues
SupabaseClient get _db => Supabase.instance.client;

// ==================== MAIN ====================
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pprqjjgbufeodoaynbfn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBwcnFqamdidWZlb2RvYXluYmZuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEyNzg1MzAsImV4cCI6MjA4Njg1NDUzMH0.YZY_2uZ9s8_WcTNNQSkaxOzDGddOEd8i5fvUiizIjc8',
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
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      primary: AppColors.navy,
    ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        side: const BorderSide(color: AppColors.navy),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.navy, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white,
    ),
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColors.gold,
      unselectedLabelColor: Colors.white70,
      indicatorColor: AppColors.gold,
    ),
  );
}

// ==================== HELPERS ====================
Future<void> _loadProfile() async {
  currentUser = null;
  final userId = _db.auth.currentUser?.id;
  if (userId == null) return;
  // Retry up to 3 times — Supabase sometimes needs a moment after signUp
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
  currentUser = null;
  myClassId   = null;
  myClassCode = null;
  myClassName = null;
  myYearLevel = null;
  if (context.mounted) {
    // ignore: use_build_context_synchronously
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashPage()),
      (_) => false,
    );
  }
}

void _showSnack(BuildContext ctx, String msg, {bool isError = false}) {
  if (!ctx.mounted) return;
  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
    content: Text(msg),
    backgroundColor: isError ? AppColors.red : AppColors.green,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    margin: const EdgeInsets.all(12),
  ));
}

String _fmtDate(dynamic raw) {
  if (raw == null) return '';
  try {
    final d = DateTime.parse(raw.toString()).toLocal();
    return '${d.year}/${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}';
  } catch (_) {
    return raw.toString();
  }
}

// FIX: helper to safely cast Supabase response to typed list
List<Map<String, dynamic>> _toList(dynamic raw) =>
    List<Map<String, dynamic>>.from(raw as List);

// ==================== SHARED WIDGETS ====================

/// Header banner — 3 Arabic lines on the left + logo on the right
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
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.schoolName,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.churchName,
                  style: TextStyle(
                    color: Colors.white.withAlpha(217), // 0.85 * 255
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.motto,
                  style: TextStyle(
                    color: Colors.white.withAlpha(166), // 0.65 * 255
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (showLogo) ...[
            const SizedBox(width: 12),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold, width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(51), blurRadius: 8),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/logo.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.church, size: 36, color: AppColors.navy),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// FIX: removed Colors.white references from AppColors static const —
// now using Colors.white directly everywhere (avoids const Color issue)

Widget _statCard(String value, String label, Color color, IconData icon) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: color.withAlpha(26),   // 0.1 * 255
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(77)), // 0.3 * 255
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(fontSize: 11, color: color.withAlpha(204))), // 0.8 * 255
      ],
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
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Check for password reset code FIRST before anything else
    if (kIsWeb) {
      final code = Uri.base.queryParameters['code'];
      if (code != null && code.isNotEmpty) {
        try {
          // Sign out any existing session first
          await _db.auth.signOut();
          // Exchange code for session
          await _db.auth.exchangeCodeForSession(code);
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ResetPasswordPage()),
            );
          }
          return;
        } catch (e) {
          debugPrint('Code exchange error: $e');
        }
      }
    }

    await Future.delayed(const Duration(milliseconds: 1500));
    final session = _db.auth.currentSession;
    if (session != null) {
      await _loadProfile();
      if (mounted) _navigate();
    } else {
      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    }
  }

  void _navigate() {
    final role = currentUser?['role'] ?? 'student';
    final Widget page = role == 'super_admin'
        ? const SuperAdminPage()
        : role == 'admin'
            ? const AdminPage()
            : const StudentPage();
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(77),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                            Icons.church,
                            size: 50,
                            color: AppColors.navy,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      AppStrings.schoolName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.churchName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(204),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.motto,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(153),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 40),
              child: CircularProgressIndicator(color: AppColors.gold, strokeWidth: 2),
            ),
          ],
        ),
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
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Please fill all fields');
      return;
    }
    setState(() { _loading = true; _error = null; });
    // Clear old session data before new login
    currentUser = null;
    myClassId   = null;
    myClassCode = null;
    myClassName = null;
    myYearLevel = null;
    try {
      await _db.auth.signInWithPassword(email: email, password: pass);
      // Wait for session to be fully ready
      await Future.delayed(const Duration(milliseconds: 1000));
      await _loadProfile();
      if (!mounted) return;
      debugPrint('Role after login: ${currentUser?['role']}');
      final role = currentUser?['role'] ?? 'student';
      final Widget page = role == 'super_admin'
          ? const SuperAdminPage()
          : role == 'admin'
              ? const AdminPage()
              : const StudentPage();
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
      body: Column(
        children: [
          const SchoolBanner(topPadding: 30),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navy,
                      ),
                    ),
                    const Text(
                      'Sign in to continue',
                      style: TextStyle(color: AppColors.grey),
                    ),
                    const SizedBox(height: 28),
                    if (_error != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.redBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.red.withAlpha(77)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.error_outline, color: AppColors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.red))),
                        ]),
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                        ),
                        child: const Text(
                          'Forgot password?',
                          style: TextStyle(color: AppColors.navy),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_loading)
                      const Center(child: CircularProgressIndicator(color: AppColors.navy))
                    else
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Sign In',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpPage()),
                      ),
                      child: const Text('Create New Account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() { _emailCtrl.dispose(); super.dispose(); }

  Future<void> _send() async {
    if (_emailCtrl.text.trim().isEmpty) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Please enter your email', isError: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final redirectUrl = kIsWeb
          ? '${Uri.base.origin}/'
          : 'io.supabase.smartschool://reset-callback/';
      await _db.auth.resetPasswordForEmail(
        _emailCtrl.text.trim(),
        redirectTo: redirectUrl,
      );
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
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sent ? _sentView() : _formView(),
        ),
      )),
    ]),
  );

  Widget _formView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy),
      ),
      const Text('Reset Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
      const SizedBox(height: 8),
      const Text('Enter your email and we will send a reset link.',
          style: TextStyle(color: AppColors.grey)),
      const SizedBox(height: 32),
      TextFormField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: 'Email', prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
      const SizedBox(height: 24),
      if (_loading)
        const Center(child: CircularProgressIndicator(color: AppColors.navy))
      else
        ElevatedButton(
          onPressed: _send,
          child: const Text('Send Reset Link',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
    ],
  );

  Widget _sentView() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const SizedBox(height: 60),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.greenBg, shape: BoxShape.circle),
        child: const Icon(Icons.mark_email_read_outlined, size: 60, color: AppColors.green),
      ),
      const SizedBox(height: 24),
      const Text('Email Sent!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
      const SizedBox(height: 12),
      Text(
        'A reset link was sent to\n${_emailCtrl.text.trim()}\n\nOpen your email and tap the link.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.grey, height: 1.6),
      ),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Back to Login'),
      ),
    ],
  );
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
  bool _loading = false;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _done = false;

  @override
  void dispose() { _newCtrl.dispose(); _confirmCtrl.dispose(); super.dispose(); }

  Future<void> _reset() async {
    final pass    = _newCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (pass.isEmpty || confirm.isEmpty) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Please fill all fields', isError: true); return;
    }
    if (pass != confirm) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Passwords do not match', isError: true); return;
    }
    if (pass.length < 6) {
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Password must be at least 6 characters', isError: true); return;
    }
    setState(() => _loading = true);
    try {
      await _db.auth.updateUser(UserAttributes(password: pass));
      // Sign out after reset so user logs in fresh
      await _db.auth.signOut();
      if (mounted) setState(() => _done = true);
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
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _done ? _doneView() : _formView(),
        ),
      )),
    ]),
  );

  Widget _formView() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 8),
      const Text('Set New Password',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
      const SizedBox(height: 8),
      const Text('Enter your new password below.',
          style: TextStyle(color: AppColors.grey)),
      const SizedBox(height: 28),
      TextFormField(
        controller: _newCtrl,
        obscureText: _obscure1,
        decoration: InputDecoration(
          labelText: 'New Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure1 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscure1 = !_obscure1),
          ),
        ),
      ),
      const SizedBox(height: 16),
      TextFormField(
        controller: _confirmCtrl,
        obscureText: _obscure2,
        decoration: InputDecoration(
          labelText: 'Confirm Password',
          prefixIcon: const Icon(Icons.lock_outline),
          suffixIcon: IconButton(
            icon: Icon(_obscure2 ? Icons.visibility_outlined : Icons.visibility_off_outlined),
            onPressed: () => setState(() => _obscure2 = !_obscure2),
          ),
        ),
      ),
      const SizedBox(height: 24),
      if (_loading)
        const Center(child: CircularProgressIndicator(color: AppColors.navy))
      else
        ElevatedButton(
          onPressed: _reset,
          child: const Text('Save New Password',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
    ],
  );

  Widget _doneView() => Column(
    children: [
      const SizedBox(height: 60),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.greenBg, shape: BoxShape.circle),
        child: const Icon(Icons.check_circle_outline, size: 60, color: AppColors.green),
      ),
      const SizedBox(height: 24),
      const Text('Password Changed!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.navy)),
      const SizedBox(height: 12),
      const Text(
        'Your password has been updated successfully.',
        textAlign: TextAlign.center,
        style: TextStyle(color: AppColors.grey),
      ),
      const SizedBox(height: 32),
      ElevatedButton(
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        ),
        child: const Text('Sign In'),
      ),
    ],
  );
}

// ==================== SIGN UP ====================
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _dobCtrl     = TextEditingController();
  final _codeCtrl    = TextEditingController();
  String _role = 'student';
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _confirmCtrl.dispose(); _dobCtrl.dispose(); _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );
    if (d != null) _dobCtrl.text = d.toIso8601String().split('T')[0];
  }

  Future<void> _signUp() async {
    final name    = _nameCtrl.text.trim();
    final email   = _emailCtrl.text.trim();
    final pass    = _passCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    final dob     = _dobCtrl.text.trim();
    final code    = _codeCtrl.text.trim().toUpperCase();

    if (name.isEmpty || email.isEmpty || pass.isEmpty || dob.isEmpty) {
      setState(() => _error = 'Please fill all required fields'); return;
    }
    if (pass != confirm) { setState(() => _error = 'Passwords do not match'); return; }
    if (pass.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }
    if (_role == 'student' && code.isEmpty) {
      setState(() => _error = 'Students must enter a class code'); return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      final res    = await _db.auth.signUp(email: email, password: pass);
      final userId = res.user?.id;
      if (userId == null) throw Exception('Failed to create account');

      String? classId;
      int?    yearLevel;

      if (_role == 'student') {
        final cls = await _db
            .from('classes')
            .select('id, year_level')
            .eq('class_code', code)
            .maybeSingle();
        if (cls == null) throw Exception('Invalid class code');
        classId   = cls['id'].toString();
        yearLevel = cls['year_level'] as int?;
      }

      await _db.from('profiles').insert({
        'id':            userId,
        'email':         email,
        'full_name':     name,
        'role':          _role,
        'date_of_birth': dob,
        'class_id':      classId,
        'year_level':    yearLevel,
        'is_active':     true,
      });

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
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28), topRight: Radius.circular(28),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.navy),
              ),
              const Text('Create Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.navy)),
            ]),
            const SizedBox(height: 12),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.redBg, borderRadius: BorderRadius.circular(10),
                ),
                child: Text(_error!, style: const TextStyle(color: AppColors.red)),
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Full Name *', prefixIcon: Icon(Icons.person_outline))),
            const SizedBox(height: 12),
            TextFormField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email *', prefixIcon: Icon(Icons.email_outlined))),
            const SizedBox(height: 12),
            TextFormField(controller: _passCtrl, obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Password *',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                )),
            const SizedBox(height: 12),
            TextFormField(controller: _confirmCtrl, obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirm Password *', prefixIcon: Icon(Icons.lock_outline))),
            const SizedBox(height: 12),
            TextFormField(controller: _dobCtrl, readOnly: true, onTap: _pickDate,
                decoration: const InputDecoration(labelText: 'Date of Birth *', prefixIcon: Icon(Icons.cake_outlined))),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _role,
                  isExpanded: true,
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
              TextFormField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(labelText: 'Class Code *', prefixIcon: Icon(Icons.qr_code)),
              ),
            ],
            const SizedBox(height: 24),
            if (_loading)
              const Center(child: CircularProgressIndicator(color: AppColors.navy))
            else
              ElevatedButton(
                onPressed: _signUp,
                child: const Text('Create Account',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Already have an account? Sign in',
                  style: TextStyle(color: AppColors.navy)),
            ),
          ]),
        ),
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

class _SuperAdminPageState extends State<SuperAdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // FIX: explicit typed list — List.generate with typed inner list
  final List<List<Map<String, dynamic>>> _yearStudents =
      List.generate(5, (_) => <Map<String, dynamic>>[]);

  List<Map<String, dynamic>> _allAdmins  = [];
  List<Map<String, dynamic>> _allClasses = [];
  bool _loading = true;

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAll();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      // FIX: explicit cast using _toList helper
      final raw = await _db
          .from('profiles')
          .select()
          .eq('role', 'student')
          .order('full_name');
      final students = _toList(raw);

      // Group students by class year_level from classes table
      final rawClasses2 = await _db.from('classes').select('id, year_level');
      final classYearMap = <String, int>{};
      for (final c in rawClasses2) {
        classYearMap[c['id'].toString()] = (c['year_level'] as int?) ?? 1;
      }

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

      if (mounted) {
        setState(() {
          _allAdmins  = _toList(rawAdmins);
          _allClasses = _toList(rawClasses);
        });
      }
    } catch (e) {
      debugPrint('SuperAdmin load: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _promoteStudent(Map<String, dynamic> student) async {
    final current = (student['year_level'] as int?) ?? 1;
    // ignore: use_build_context_synchronously
    if (current >= 5) { _showSnack(context, 'Student is already in the final year'); return; }
    final newYear      = current + 1;
    final nextClasses  = _allClasses.where((c) => (c['year_level'] as int?) == newYear).toList();
    // ignore: use_build_context_synchronously
    if (nextClasses.isEmpty) { _showSnack(context, 'No class found for Year $newYear', isError: true); return; }

    String? selectedClassId = nextClasses.first['id'].toString();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Promote: ${student['full_name']}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Year $current  →  Year $newYear'),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(labelText: 'Select Class', border: OutlineInputBorder()),
              items: nextClasses
                  .map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? '')))
                  .toList(),
              onChanged: (v) => set(() => selectedClassId = v),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Promote')),
          ],
        ),
      ),
    );

    if (confirm == true && mounted) {
      try {
        final sid = student['id'].toString();
        // Move student to new class
        await _db.from('profiles')
            .update({'year_level': newYear, 'class_id': selectedClassId})
            .eq('id', sid);
        // Clear old records so student starts fresh
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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Move Student by Email'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Student Email', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: selectedClassId,
              decoration: const InputDecoration(labelText: 'Target Class', border: OutlineInputBorder()),
              items: _allClasses.map((c) => DropdownMenuItem(
                value: c['id'].toString(),
                child: Text(
                  '${AppStrings.yearNames[((c['year_level'] as int?) ?? 1) - 1]} — ${c['name'] ?? ''}',
                ),
              )).toList(),
              onChanged: (v) => set(() => selectedClassId = v),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (emailCtrl.text.trim().isEmpty || selectedClassId == null) return;
                Navigator.pop(ctx);
                try {
                  final cls = _allClasses.firstWhere((c) => c['id'].toString() == selectedClassId);
                  final student = await _db.from('profiles')
                      .select('id')
                      .eq('email', emailCtrl.text.trim())
                      .single();
                  final sid = student['id'].toString();
                  await _db.from('profiles')
                      .update({'class_id': selectedClassId, 'year_level': cls['year_level']})
                      .eq('id', sid);
                  // Clear old records
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
        ),
      ),
    );
    emailCtrl.dispose();
  }

  Future<void> _removeStudent(Map<String, dynamic> student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Student'),
        content: Text('Remove ${student['full_name']} from school?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      try {
        await _db.from('profiles')
            .update({'is_active': false, 'class_id': null})
            .eq('id', student['id'].toString());
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Class'),
        content: Text('Delete "${cls['name']}"? This will remove all lessons and data inside it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
    int     selectedYear    = 1;
    String? selectedAdminId;

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: const Text('Create New Class'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Class Name', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: selectedYear,
                decoration: const InputDecoration(labelText: 'Year Level', border: OutlineInputBorder()),
                items: List.generate(5, (i) => DropdownMenuItem(value: i + 1, child: Text(AppStrings.yearNames[i]))),
                onChanged: (v) => set(() => selectedYear = v!),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: selectedAdminId,
                decoration: const InputDecoration(labelText: 'Assign Admin (optional)', border: OutlineInputBorder()),
                items: _allAdmins
                    .map((a) => DropdownMenuItem(value: a['id'].toString(), child: Text(a['full_name'] ?? '')))
                    .toList(),
                onChanged: (v) => set(() => selectedAdminId = v),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Create')),
          ],
        ),
      ),
    );

    if (result == true && nameCtrl.text.isNotEmpty && mounted) {
      try {
        const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
        final rng  = DateTime.now().microsecondsSinceEpoch;
        final code = List.generate(6, (i) {
          final seed = (rng ~/ (i + 1)) ^ (rng << (i * 3)) ^ (i * 104729);
          return chars[seed.abs() % chars.length];
        }).join();
        final inserted = await _db.from('classes').insert({
          'name':       nameCtrl.text.trim(),
          'year_level': selectedYear,
          'admin_id':   selectedAdminId,
          'class_code': code,
        }).select().single();
        if (selectedAdminId != null) {
          await _db.from('profiles').update({
            'class_id':   inserted['id'],
            'year_level': selectedYear,
          }).eq('id', selectedAdminId!);
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
        Container(
          color: AppColors.navy,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 0, left: 16, right: 16,
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.church, color: AppColors.navy, size: 24)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text(AppStrings.schoolName,
                    style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.bold)),
                Text(
                  currentUser?['full_name'] as String? ?? 'Super Admin',
                  style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 11),
                ),
              ])),
              // FIX: explicit type parameter PopupMenuButton<String>
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'email', child: Row(children: [Icon(Icons.transfer_within_a_station), SizedBox(width: 8), Text('Move Student by Email')])),
                  PopupMenuItem(value: 'class', child: Row(children: [Icon(Icons.add_circle_outline), SizedBox(width: 8), Text('Create Class')])),
                  PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: AppColors.red), SizedBox(width: 8), Text('Sign Out', style: TextStyle(color: AppColors.red))])),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ]),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : TabBarView(
                    controller: _tabController,
                    children: List.generate(5, (i) => _yearTab(i)),
                  ),
          ),
        ),
      ]),
    );
  }

  Widget _yearTab(int yearIndex) {
    final students    = _yearStudents[yearIndex];
    final yearClasses = _allClasses.where((c) => (c['year_level'] as int?) == yearIndex + 1).toList();

    return RefreshIndicator(
      onRefresh: _loadAll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (yearClasses.isNotEmpty) ...[
            Card(
              color: AppColors.goldLight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [
                    Icon(Icons.qr_code, color: AppColors.navy, size: 18),
                    SizedBox(width: 8),
                    Text('Class Codes', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
                  ]),
                  const SizedBox(height: 10),
                  ...yearClasses.map((c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(child: Text(c['name'] ?? '', style: const TextStyle(color: AppColors.navy))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(8)),
                        child: Text(c['class_code'] ?? '',
                            style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 16)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                        tooltip: 'Delete Class',
                        onPressed: () => _deleteClass(c),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ]),
                  )),
                ]),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(children: [
            Text(AppStrings.yearNames[yearIndex],
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
              child: Text('${students.length}', style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          if (students.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(children: [
                Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text('No students in ${AppStrings.yearNames[yearIndex]}',
                    style: const TextStyle(color: AppColors.grey)),
              ]),
            )
          else
            ...students.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.navy,
                  child: Text(
                    (s['full_name'] as String? ?? '?').isNotEmpty
                        ? (s['full_name'] as String)[0]
                        : '?',
                    style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(s['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(s['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
                // FIX: explicit type PopupMenuButton<String>
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.grey),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'promote', child: Row(children: [Icon(Icons.arrow_upward, color: AppColors.green, size: 18), SizedBox(width: 8), Text('Promote to Next Year')])),
                    PopupMenuItem(value: 'remove',  child: Row(children: [Icon(Icons.remove_circle_outline, color: AppColors.red, size: 18), SizedBox(width: 8), Text('Remove', style: TextStyle(color: AppColors.red))])),
                  ],
                  onSelected: (String v) {
                    if (v == 'promote') _promoteStudent(s);
                    if (v == 'remove')  _removeStudent(s);
                  },
                ),
              ),
            )),
        ],
      ),
    );
  }
}

// ==================== ADMIN PAGE ====================
class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _lessons  = [];
  bool _loading = true;

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      if (myClassId == null) {
        final cls = await _db
            .from('classes')
            .select()
            .eq('admin_id', currentUser!['id'].toString())
            .maybeSingle();
        if (cls != null) {
          myClassId   = cls['id'].toString();
          myClassCode = cls['class_code'] as String?;
          myClassName = cls['name'] as String?;
        }
      }
      if (myClassId != null) {
        final rawS = await _db
            .from('profiles')
            .select()
            .eq('class_id', myClassId!)
            .eq('role', 'student')
            .order('full_name');
        final rawL = await _db
            .from('lessons')
            .select()
            .eq('class_id', myClassId!)
            .order('created_at', ascending: false);
        // FIX: use _toList helper for proper typing
        if (mounted) {
          setState(() {
            _students = _toList(rawS);
            _lessons  = _toList(rawL);
          });
        }
      }
    } catch (e) {
      debugPrint('Admin load: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _addLesson() async {
    final titleCtrl   = TextEditingController();
    final contentCtrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Lesson'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: titleCtrl,
              decoration: const InputDecoration(labelText: 'Lesson Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: contentCtrl, maxLines: 5,
              decoration: const InputDecoration(labelText: 'Lesson Content', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Add')),
        ],
      ),
    );

    final titleText   = titleCtrl.text.trim();
    final contentText = contentCtrl.text.trim();
    titleCtrl.dispose();
    contentCtrl.dispose();

    if (ok == true && titleText.isNotEmpty && mounted) {
      try {
        await _db.from('lessons').insert({
          'class_id': myClassId,
          'title':    titleText,
          'content':  contentText,
        });
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
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Lesson'),
        content: const Text('Are you sure you want to delete this lesson?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      await _db.from('lessons').delete().eq('id', id);
      _loadData();
      // ignore: use_build_context_synchronously
      _showSnack(context, 'Lesson deleted');
    }
  }

  Future<void> _addGrade(Map<String, dynamic> student) async {
    final gradeCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String gradeType = 'quiz';

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Add Grade — ${student['full_name']}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: gradeCtrl, keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Grade', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: gradeType,
              decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'quiz',     child: Text('📝 Quiz')),
                DropdownMenuItem(value: 'exam',     child: Text('📋 Exam')),
                DropdownMenuItem(value: 'homework', child: Text('📚 Homework')),
              ],
              onChanged: (v) => set(() => gradeType = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    final gradeText = gradeCtrl.text.trim();
    final notesText = notesCtrl.text.trim();
    gradeCtrl.dispose();
    notesCtrl.dispose();

    if (ok == true && gradeText.isNotEmpty && mounted) {
      try {
        await _db.from('grades').insert({
          'student_id':  student['id'].toString(),
          'class_id':    myClassId,
          'grade_value': double.parse(gradeText),
          'grade_type':  gradeType,
          'notes':       notesText,
        });
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Attendance — ${student['full_name']}'),
          content: DropdownButtonFormField<String>(
            initialValue: status,
            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'present', child: Text('✅ Present')),
              DropdownMenuItem(value: 'absent',  child: Text('❌ Absent')),
              DropdownMenuItem(value: 'late',    child: Text('⏰ Late')),
            ],
            onChanged: (v) => set(() => status = v!),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (ok == true && mounted) {
      try {
        await _db.from('attendance').insert({
          'student_id':      student['id'].toString(),
          'class_id':        myClassId,
          'status':          status,
          'attendance_date': DateTime.now().toIso8601String().split('T')[0],
        });
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

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => AlertDialog(
          title: Text('Behavior Note — ${student['full_name']}'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: noteType,
              decoration: const InputDecoration(labelText: 'Note Type', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'positive', child: Text('🌟 Positive')),
                DropdownMenuItem(value: 'warning',  child: Text('⚠️ Warning')),
                DropdownMenuItem(value: 'negative', child: Text('❌ Negative')),
              ],
              onChanged: (v) => set(() => noteType = v!),
            ),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Save')),
          ],
        ),
      ),
    );

    final descText = descCtrl.text.trim();
    descCtrl.dispose();

    if (ok == true && descText.isNotEmpty && mounted) {
      try {
        await _db.from('behavior_notes').insert({
          'student_id':  student['id'].toString(),
          'admin_id':    currentUser!['id'].toString(),
          'note_type':   noteType,
          'description': descText,
        });
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
    borderRadius: BorderRadius.circular(8),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(emoji, style: const TextStyle(fontSize: 20)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Column(children: [
        Container(
          color: AppColors.navy,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 0, left: 16, right: 16,
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.church, color: AppColors.navy, size: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(myClassName ?? 'My Class',
                    style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.bold)),
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(4)),
                    child: const Text('ADMIN', style: TextStyle(color: AppColors.navy, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Flexible(child: Text(
                    currentUser?['full_name'] as String? ?? '',
                    style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  )),
                ]),
              ])),
              if (myClassCode != null)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.gold),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(myClassCode!,
                      style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontFamily: 'Courier', fontSize: 14)),
                ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => _logout(context),
              ),
            ]),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Lessons'),
                Tab(text: 'Students'),
                Tab(text: 'Daily Attendance'),
              ],
              indicatorColor: AppColors.gold,
              labelColor: AppColors.gold,
              unselectedLabelColor: Colors.white54,
            ),
          ]),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : myClassId == null
                    ? const Center(
                        child: Text(
                          'You have not been assigned to a class yet.\nContact the Super Admin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.grey),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [_lessonsTab(), _studentsTab(), _dailyTab()],
                      ),
          ),
        ),
      ]),
      floatingActionButton: myClassId != null && !_tabController.indexIsChanging && _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _addLesson,
              backgroundColor: AppColors.navy,
              icon: const Icon(Icons.add),
              label: const Text('New Lesson'),
            )
          : null,
    );
  }

  Widget _lessonsTab() {
    if (_lessons.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.menu_book_outlined, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text('No lessons yet. Tap + to add one.', style: TextStyle(color: AppColors.grey)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (_, i) {
        final l = _lessons[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              child: Text('${i + 1}', style: const TextStyle(color: AppColors.gold)),
            ),
            title: Text(l['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(l['content'] ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.grey)),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.red),
              onPressed: () => _deleteLesson(l['id'].toString()),
            ),
            onTap: () => _showLessonSheet(context, l),
          ),
        );
      },
    );
  }

  void _showLessonSheet(BuildContext context, Map<String, dynamic> l) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
            )),
            const SizedBox(height: 20),
            Text(l['title'] ?? '',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.navy)),
            const Divider(height: 24),
            Expanded(child: SingleChildScrollView(
              controller: ctrl,
              child: Text(l['content'] ?? '', style: const TextStyle(height: 1.8, fontSize: 15)),
            )),
          ]),
        ),
      ),
    );
  }

  Widget _studentsTab() {
    if (_students.isEmpty) {
      return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        Text(
          'No students yet.\nClass code: ${myClassCode ?? ''}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.grey),
        ),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _students.length,
      itemBuilder: (_, i) {
        final s = _students[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              child: Text(
                (s['full_name'] as String? ?? '?').isNotEmpty
                    ? (s['full_name'] as String)[0]
                    : '?',
                style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(s['full_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(s['email'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            // FIX: explicit type parameter
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.grey),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'view',     child: Row(children: [Icon(Icons.visibility_outlined, size: 18), SizedBox(width: 8), Text('View Details')])),
                PopupMenuItem(value: 'grade',    child: Row(children: [Icon(Icons.grade_outlined, size: 18, color: AppColors.blue), SizedBox(width: 8), Text('Add Grade')])),
                PopupMenuItem(value: 'attend',   child: Row(children: [Icon(Icons.how_to_reg_outlined, size: 18, color: AppColors.green), SizedBox(width: 8), Text('Record Attendance')])),
                PopupMenuItem(value: 'behavior', child: Row(children: [Icon(Icons.psychology_outlined, size: 18, color: AppColors.orange), SizedBox(width: 8), Text('Behavior Note')])),
              ],
              onSelected: (String v) {
                if (v == 'view') {
                  // ignore: use_build_context_synchronously
                  Navigator.push(context, MaterialPageRoute(builder: (_) => StudentDetailPage(student: s)));
                } else if (v == 'grade') {
                  _addGrade(s);
                } else if (v == 'attend') {
                  _markAttendance(s);
                } else if (v == 'behavior') {
                  _addBehavior(s);
                }
              },
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => StudentDetailPage(student: s)),
            ),
          ),
        );
      },
    );
  }

  Widget _dailyTab() {
    if (_students.isEmpty) {
      return const Center(child: Text('No students found.', style: TextStyle(color: AppColors.grey)));
    }
    final today = DateTime.now().toIso8601String().split('T')[0];
    return Column(children: [
      Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.goldLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gold.withAlpha(102)),
        ),
        child: Row(children: [
          const Icon(Icons.calendar_today, color: AppColors.navy, size: 18),
          const SizedBox(width: 8),
          Text("Today's Attendance — $today",
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _students.length,
          itemBuilder: (_, i) {
            final s = _students[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.navy,
                  child: Text(
                    (s['full_name'] as String? ?? '?').isNotEmpty
                        ? (s['full_name'] as String)[0]
                        : '?',
                    style: const TextStyle(color: AppColors.gold),
                  ),
                ),
                title: Text(s['full_name'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _quickBtn('✅', AppColors.green, () async {
                      try {
                        await _db.from('attendance').insert({
                          'student_id': s['id'].toString(),
                          'class_id': myClassId,
                          'status': 'present',
                          'attendance_date': today,
                        });
                        // ignore: use_build_context_synchronously
                        _showSnack(context, '${s['full_name']}: Present');
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        _showSnack(context, 'Error: $e', isError: true);
                      }
                    }),
                    _quickBtn('❌', AppColors.red, () async {
                      try {
                        await _db.from('attendance').insert({
                          'student_id': s['id'].toString(),
                          'class_id': myClassId,
                          'status': 'absent',
                          'attendance_date': today,
                        });
                        // ignore: use_build_context_synchronously
                        _showSnack(context, '${s['full_name']}: Absent', isError: true);
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        _showSnack(context, 'Error: $e', isError: true);
                      }
                    }),
                    _quickBtn('⏰', AppColors.orange, () async {
                      try {
                        await _db.from('attendance').insert({
                          'student_id': s['id'].toString(),
                          'class_id': myClassId,
                          'status': 'late',
                          'attendance_date': today,
                        });
                        // ignore: use_build_context_synchronously
                        _showSnack(context, '${s['full_name']}: Late');
                      } catch (e) {
                        // ignore: use_build_context_synchronously
                        _showSnack(context, 'Error: $e', isError: true);
                      }
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
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

class _StudentDetailPageState extends State<StudentDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _grades     = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _behavior   = [];
  bool _loading = true;

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _load();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final sid = widget.student['id'].toString();
      final rawG = await _db.from('grades').select().eq('student_id', sid).order('created_at', ascending: false);
      final rawA = await _db.from('attendance').select().eq('student_id', sid).order('attendance_date', ascending: false);
      final rawB = await _db.from('behavior_notes').select().eq('student_id', sid).order('created_at', ascending: false);
      // FIX: typed lists
      if (mounted) {
        setState(() {
          _grades     = _toList(rawG);
          _attendance = _toList(rawA);
          _behavior   = _toList(rawB);
        });
      }
    } catch (e) {
      debugPrint('StudentDetail: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
        : TabBarView(
            controller: _tabController,
            children: [_gradesTab(), _attendanceTab(), _behaviorTab()],
          ),
  );

  Widget _gradesTab() {
    if (_grades.isEmpty) return const Center(child: Text('No grades yet.', style: TextStyle(color: AppColors.grey)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _grades.length,
      itemBuilder: (_, i) {
        final g   = _grades[i];
        final v   = (g['grade_value'] as num? ?? 0).toDouble();
        final ok  = v >= 50;
        const tMap = {'quiz': '📝 Quiz', 'exam': '📋 Exam', 'homework': '📚 Homework'};
        final notes = g['notes'] as String?;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: ok ? AppColors.greenBg : AppColors.redBg,
              child: Text(v.toStringAsFixed(0),
                  style: TextStyle(color: ok ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold, fontSize: 13)),
            ),
            title: Text(tMap[g['grade_type'] as String? ?? 'quiz'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: (notes != null && notes.isNotEmpty)
                ? Text(notes, style: const TextStyle(color: AppColors.grey))
                : null,
            trailing: Text(_fmtDate(g['created_at']), style: const TextStyle(color: AppColors.grey, fontSize: 11)),
          ),
        );
      },
    );
  }

  Widget _attendanceTab() {
    final present = _attendance.where((a) => a['status'] == 'present').length;
    final absent  = _attendance.where((a) => a['status'] == 'absent').length;
    final late    = _attendance.where((a) => a['status'] == 'late').length;

    const statusInfo = {
      'present': ('✅ Present', AppColors.green),
      'absent':  ('❌ Absent',  AppColors.red),
      'late':    ('⏰ Late',    AppColors.orange),
    };

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _statCard('$present', 'Present', AppColors.green,  Icons.check_circle_outline),
          _statCard('$absent',  'Absent',  AppColors.red,    Icons.cancel_outlined),
          _statCard('$late',    'Late',    AppColors.orange, Icons.schedule_outlined),
        ]),
      ),
      Expanded(
        child: _attendance.isEmpty
            ? const Center(child: Text('No attendance records.', style: TextStyle(color: AppColors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _attendance.length,
                itemBuilder: (_, i) {
                  final a      = _attendance[i];
                  final key    = a['status'] as String? ?? 'present';
                  final info   = statusInfo[key] ?? ('? Unknown', AppColors.grey);
                  final label  = info.$1;
                  final color  = info.$2;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: Text(label.split(' ')[0], style: const TextStyle(fontSize: 22)),
                      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                      trailing: Text(a['attendance_date'] as String? ?? '',
                          style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  Widget _behaviorTab() {
    final pos = _behavior.where((b) => b['note_type'] == 'positive').length;
    final war = _behavior.where((b) => b['note_type'] == 'warning').length;
    final neg = _behavior.where((b) => b['note_type'] == 'negative').length;

    const noteInfo = {
      'positive': ('🌟 Positive', AppColors.green),
      'warning':  ('⚠️ Warning',  AppColors.orange),
      'negative': ('❌ Negative', AppColors.red),
    };

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _statCard('$pos', 'Positive', AppColors.green,  Icons.star_outline),
          _statCard('$war', 'Warning',  AppColors.orange, Icons.warning_amber_outlined),
          _statCard('$neg', 'Negative', AppColors.red,    Icons.thumb_down_outlined),
        ]),
      ),
      Expanded(
        child: _behavior.isEmpty
            ? const Center(child: Text('No behavior notes.', style: TextStyle(color: AppColors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _behavior.length,
                itemBuilder: (_, i) {
                  final b     = _behavior[i];
                  final key   = b['note_type'] as String? ?? 'positive';
                  final info  = noteInfo[key] ?? ('? Unknown', AppColors.grey);
                  final label = info.$1;
                  final color = info.$2;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: color, width: 4)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                            const Spacer(),
                            Text(_fmtDate(b['created_at']),
                                style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                          ]),
                          const SizedBox(height: 6),
                          Text(b['description'] as String? ?? '',
                              style: const TextStyle(height: 1.5)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
      ),
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
  List<Map<String, dynamic>> _lessons    = [];
  List<Map<String, dynamic>> _grades     = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _behavior   = [];
  bool _loading = true;

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      if (myClassId != null) {
        final sid   = currentUser!['id'].toString();
        final rawL  = await _db.from('lessons').select().eq('class_id', myClassId!).order('created_at', ascending: false);
        final rawG  = await _db.from('grades').select().eq('student_id', sid).order('created_at', ascending: false);
        final rawA  = await _db.from('attendance').select().eq('student_id', sid).eq('class_id', myClassId!).order('attendance_date', ascending: false);
        final rawB  = await _db.from('behavior_notes').select().eq('student_id', sid).order('created_at', ascending: false);
        // FIX: all typed with _toList
        if (mounted) {
          setState(() {
            _lessons    = _toList(rawL);
            _grades     = _toList(rawG);
            _attendance = _toList(rawA);
            _behavior   = _toList(rawB);
          });
        }
      }
    } catch (e) {
      debugPrint('Student load: $e');
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _joinClass() async {
    final ctrl = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join a Class'),
        content: TextField(
          controller: ctrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'Class Code', border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Join')),
        ],
      ),
    );

    final codeText = ctrl.text.trim().toUpperCase();
    ctrl.dispose();

    if (ok == true && codeText.isNotEmpty && mounted) {
      try {
        final cls = await _db
            .from('classes')
            .select()
            .eq('class_code', codeText)
            .maybeSingle();
        if (cls != null) {
          await _db.from('profiles')
              .update({'class_id': cls['id'].toString(), 'year_level': cls['year_level']})
              .eq('id', currentUser!['id'].toString());
          currentUser!['class_id']   = cls['id'];
          myClassId   = cls['id'].toString();
          myClassCode = cls['class_code'] as String?;
          myClassName = cls['name'] as String?;
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

  String _yearLabel() {
    final y = currentUser?['year_level'] as int?;
    if (y == null || y < 1 || y > 5) return '';
    return AppStrings.yearNames[y - 1];
  }

  @override
  Widget build(BuildContext context) {
    // Safety: if this user is actually admin/super_admin, redirect correctly
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
        Container(
          color: AppColors.navy,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 8,
            bottom: 0, left: 16, right: 16,
          ),
          child: Column(children: [
            Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2),
                ),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.church, color: AppColors.navy, size: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  currentUser?['full_name'] as String? ?? '',
                  style: const TextStyle(color: AppColors.gold, fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  myClassName != null
                      ? '$myClassName • ${_yearLabel()}'
                      : AppStrings.schoolName,
                  style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 11),
                ),
              ])),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white70),
                onPressed: () => _logout(context),
              ),
            ]),
            const SizedBox(height: 12),
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: const [
                Tab(text: 'Lessons'),
                Tab(text: 'Grades'),
                Tab(text: 'Attendance'),
                Tab(text: 'Behavior'),
              ],
              indicatorColor: AppColors.gold,
              labelColor: AppColors.gold,
              unselectedLabelColor: Colors.white54,
            ),
          ]),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.navy))
                : myClassId == null
                    ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.class_outlined, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('You have not joined a class yet.',
                            style: TextStyle(fontSize: 16, color: AppColors.grey)),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: ElevatedButton.icon(
                            onPressed: _joinClass,
                            icon: const Icon(Icons.add),
                            label: const Text('Join a Class'),
                          ),
                        ),
                      ]))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _lessonsTab(),
                          _gradesTab(),
                          _attendanceTab(),
                          _behaviorTab(),
                        ],
                      ),
          ),
        ),
      ]),
    );
  }

  Widget _lessonsTab() {
    if (_lessons.isEmpty) {
      return const Center(child: Text('No lessons yet.', style: TextStyle(color: AppColors.grey)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _lessons.length,
      itemBuilder: (_, i) {
        final l = _lessons[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.navy,
              child: Text('${i + 1}', style: const TextStyle(color: AppColors.gold)),
            ),
            title: Text(l['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.navy)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(l['content'] ?? '', style: const TextStyle(height: 1.8)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _gradesTab() {
    if (_grades.isEmpty) {
      return const Center(child: Text('No grades yet.', style: TextStyle(color: AppColors.grey)));
    }
    final avg = _grades
        .map((g) => (g['grade_value'] as num? ?? 0).toDouble())
        .reduce((a, b) => a + b) / _grades.length;

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.navy, AppColors.navyLight]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.bar_chart, color: AppColors.gold, size: 40),
            const SizedBox(width: 16),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Overall Average',
                  style: TextStyle(color: Colors.white.withAlpha(204), fontSize: 13)),
              Text(avg.toStringAsFixed(1),
                  style: const TextStyle(color: AppColors.gold, fontSize: 28, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _grades.length,
          itemBuilder: (_, i) {
            final g    = _grades[i];
            final v    = (g['grade_value'] as num? ?? 0).toDouble();
            final ok   = v >= 50;
            final notes = g['notes'] as String?;
            const tMap = {'quiz': '📝 Quiz', 'exam': '📋 Exam', 'homework': '📚 Homework'};
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: ok ? AppColors.greenBg : AppColors.redBg,
                  child: Text(v.toStringAsFixed(0),
                      style: TextStyle(color: ok ? AppColors.green : AppColors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
                title: Text(tMap[g['grade_type'] as String? ?? 'quiz'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: (notes != null && notes.isNotEmpty)
                    ? Text(notes, style: const TextStyle(color: AppColors.grey))
                    : null,
                trailing: Text(_fmtDate(g['created_at']),
                    style: const TextStyle(fontSize: 11, color: AppColors.grey)),
              ),
            );
          },
        ),
      ),
    ]);
  }

  Widget _attendanceTab() {
    final present = _attendance.where((a) => a['status'] == 'present').length;
    final absent  = _attendance.where((a) => a['status'] == 'absent').length;
    final late    = _attendance.where((a) => a['status'] == 'late').length;

    const statusInfo = {
      'present': ('✅ Present', AppColors.green),
      'absent':  ('❌ Absent',  AppColors.red),
      'late':    ('⏰ Late',    AppColors.orange),
    };

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _statCard('$present', 'Present', AppColors.green,  Icons.check_circle_outline),
          _statCard('$absent',  'Absent',  AppColors.red,    Icons.cancel_outlined),
          _statCard('$late',    'Late',    AppColors.orange, Icons.schedule_outlined),
        ]),
      ),
      Expanded(
        child: _attendance.isEmpty
            ? const Center(child: Text('No attendance records.', style: TextStyle(color: AppColors.grey)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _attendance.length,
                itemBuilder: (_, i) {
                  final a     = _attendance[i];
                  final key   = a['status'] as String? ?? 'present';
                  final info  = statusInfo[key] ?? ('? Unknown', AppColors.grey);
                  final label = info.$1;
                  final color = info.$2;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 6),
                    child: ListTile(
                      dense: true,
                      leading: Text(label.split(' ')[0], style: const TextStyle(fontSize: 22)),
                      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                      trailing: Text(a['attendance_date'] as String? ?? '',
                          style: const TextStyle(color: AppColors.grey, fontSize: 12)),
                    ),
                  );
                },
              ),
      ),
    ]);
  }

  Widget _behaviorTab() {
    final pos = _behavior.where((b) => b['note_type'] == 'positive').length;
    final war = _behavior.where((b) => b['note_type'] == 'warning').length;
    final neg = _behavior.where((b) => b['note_type'] == 'negative').length;

    const noteInfo = {
      'positive': ('🌟 Positive', AppColors.green),
      'warning':  ('⚠️ Warning',  AppColors.orange),
      'negative': ('❌ Negative', AppColors.red),
    };

    return Column(children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          _statCard('$pos', 'Positive', AppColors.green,  Icons.star_outline),
          _statCard('$war', 'Warning',  AppColors.orange, Icons.warning_amber_outlined),
          _statCard('$neg', 'Negative', AppColors.red,    Icons.thumb_down_outlined),
        ]),
      ),
      Expanded(
        child: _behavior.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.psychology_outlined, size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No behavior notes.', style: TextStyle(color: AppColors.grey)),
              ]))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _behavior.length,
                itemBuilder: (_, i) {
                  final b     = _behavior[i];
                  final key   = b['note_type'] as String? ?? 'positive';
                  final info  = noteInfo[key] ?? ('? Unknown', AppColors.grey);
                  final label = info.$1;
                  final color = info.$2;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(left: BorderSide(color: color, width: 4)),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13)),
                            const Spacer(),
                            Text(_fmtDate(b['created_at']),
                                style: const TextStyle(color: AppColors.grey, fontSize: 11)),
                          ]),
                          const SizedBox(height: 6),
                          Text(b['description'] as String? ?? '',
                              style: const TextStyle(height: 1.5)),
                        ]),
                      ),
                    ),
                  );
                },
              ),
      ),
    ]);
  }
}
