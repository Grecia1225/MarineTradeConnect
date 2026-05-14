import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mtc/firebase_options.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/cart_provider.dart';
import 'package:mtc/utils/language_provider.dart';
import 'package:mtc/utils/voice_provider/voice_provider.dart';
import 'package:mtc/utils/app_localizations.dart';
import 'package:mtc/screens/auth/login_screen.dart';
import 'package:mtc/screens/auth/signup_screen.dart';
import 'package:mtc/screens/auth/role_selection_screen.dart';
import 'package:mtc/screens/auth/profile_setup_screen.dart';
import 'package:mtc/screens/home/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => VoiceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context);
    final lp = Provider.of<LanguageProvider>(context);
    final t  = tp.current;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: lp.locale,
      localeResolutionCallback: (_, supported) {
        for (final s in supported) {
          if (s.languageCode == lp.locale.languageCode) return s;
        }
        return supported.first;
      },
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), Locale('hi'), Locale('ta'),
        Locale('te'), Locale('ar'), Locale('fr'),
      ],
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(
          primary: t.primary,
          surface: t.background,
        ),
      ),
      home: const _AuthGate(),
      routes: {
        '/login':          (_) => const LoginScreen(),
        '/signup':         (_) => const SignupScreen(),
        '/role-selection': (_) => const RoleSelectionScreen(),
        '/profile-setup':  (_) => const ProfileSetup(),
        '/dashboard':      (_) => const DashboardScreen(),
      },
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  // We only listen to auth state — no Firestore on startup
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still connecting to Firebase Auth
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _Splash();
        }

        // Not logged in → login screen immediately
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // Logged in → check SharedPreferences only (zero network)
        return _PrefsRouter(uid: snapshot.data!.uid);
      },
    );
  }
}

// Reads ONLY from SharedPreferences — no network, no Firestore
class _PrefsRouter extends StatefulWidget {
  final String uid;
  const _PrefsRouter({required this.uid});

  @override
  State<_PrefsRouter> createState() => _PrefsRouterState();
}

class _PrefsRouterState extends State<_PrefsRouter> {
  Widget? _screen;

  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    try {
      final prefs          = await SharedPreferences.getInstance();
      final role           = prefs.getString('user_role_${widget.uid}') ?? '';
      final profileComplete= prefs.getBool('profile_complete_${widget.uid}') ?? false;

      Widget screen;
      if (role.isEmpty) {
        // First time — need role, but also fetch from Firestore in case
        // they previously set up on another device
        screen = await _checkFirestore();
      } else if (!profileComplete) {
        screen = const ProfileSetup();
      } else {
        screen = const DashboardScreen();
        // Sync providers silently
        if (mounted) {
          Provider.of<ThemeProvider>(context, listen: false)
              .loadThemeFromFirestore();
          Provider.of<LanguageProvider>(context, listen: false)
              .loadFromFirestore();
        }
      }

      if (mounted) setState(() => _screen = screen);
    } catch (_) {
      if (mounted) setState(() => _screen = const LoginScreen());
    }
  }

  Future<Widget> _checkFirestore() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get()
          .timeout(const Duration(seconds: 6));

      if (!doc.exists) return const RoleSelectionScreen();

      final data            = doc.data() as Map<String, dynamic>;
      final role            = (data['role'] ?? '').toString().trim();
      final profileComplete = data['profileComplete'] == true;

      // Cache it so next login is instant
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role_${widget.uid}', role);
      await prefs.setBool('profile_complete_${widget.uid}', profileComplete);

      if (role.isEmpty)      return const RoleSelectionScreen();
      if (!profileComplete)  return const ProfileSetup();
      return const DashboardScreen();
    } catch (_) {
      return const RoleSelectionScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _screen ?? const _Splash();
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) {
    final t = Provider.of<ThemeProvider>(context).current;
    return Scaffold(
      backgroundColor: t.background,
      body: Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.anchor, color: t.primary, size: 52),
          const SizedBox(height: 20),
          SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(
                color: t.primary, strokeWidth: 2),
          ),
        ]),
      ),
    );
  }
}