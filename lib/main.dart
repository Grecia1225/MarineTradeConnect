import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:mtc/firebase_options.dart';
import 'package:mtc/utils/theme_provider.dart';
import 'package:mtc/utils/cart_provider.dart';
import 'package:mtc/utils/language_provider.dart';
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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider    = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final appTheme         = themeProvider.current;

    // Non-const list because AppLocalizationsDelegate()
    // may not be const depending on your class definition
    final delegates = <LocalizationsDelegate>[
      const AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: languageProvider.locale,
      localizationsDelegates: delegates,
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
        Locale('ta'),
        Locale('te'),
        Locale('ar'),
        Locale('fr'),
      ],
      theme: ThemeData(
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.dark(
          primary: appTheme.primary,
          surface: appTheme.background,
        ),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: appTheme.background,
              body: Center(
                  child: CircularProgressIndicator(color: appTheme.primary)),
            );
          }

          if (!snapshot.hasData) return const LoginScreen();

          final user = snapshot.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            Provider.of<ThemeProvider>(context, listen: false)
                .loadThemeFromFirestore();
            Provider.of<LanguageProvider>(context, listen: false)
                .loadFromFirestore();
          });

          return FutureBuilder<DocumentSnapshot>(
            key: ValueKey(user.uid),
            future: FirebaseFirestore.instance
                .collection('users').doc(user.uid).get(),
            builder: (context, userSnap) {
              if (userSnap.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  backgroundColor: appTheme.background,
                  body: Center(
                      child: CircularProgressIndicator(
                          color: appTheme.primary)),
                );
              }

              if (!userSnap.hasData || !userSnap.data!.exists) {
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .set({
                  'uid':             user.uid,
                  'name':            user.displayName ?? '',
                  'email':           user.email ?? '',
                  'role':            '',
                  'profileComplete': false,
                  'theme':           'navy_gold',
                  'language':        'en',
                  'createdAt':       FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
                return const RoleSelectionScreen();
              }

              final data =
                  userSnap.data!.data() as Map<String, dynamic>;

              if ((data['role'] ?? '').toString().isEmpty) {
                return const RoleSelectionScreen();
              }

              if (data['profileComplete'] != true) {
                return const ProfileSetup();
              }

              return const DashboardScreen();
            },
          );
        },
      ),
      routes: {
        '/login':          (ctx) => const LoginScreen(),
        '/signup':         (ctx) => const SignupScreen(),
        '/role-selection': (ctx) => const RoleSelectionScreen(),
        '/profile-setup':  (ctx) => const ProfileSetup(),
        '/dashboard':      (ctx) => const DashboardScreen(),
      },
    );
  }
}