import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'intro_page.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'admin_page.dart';
import 'auth_service.dart';

import 'package:flutter/services.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'network_discovery.dart';
import 'config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  bool jailbroken = false;
  if (!kIsWeb) {
    try {
      jailbroken = await FlutterJailbreakDetection.jailbroken;
      if (jailbroken) {
        print('WARNING: Device appears to be jailbroken/rooted!');
      }
    } catch (e) {
      print('Jailbreak detection error: $e');
      jailbroken = false;
    }
  }

  if (!kIsWeb) {
    print('📡 Searching for Lunchify backend server...');
    String? discoveredUrl = await NetworkDiscovery.discoverServer();
    if (discoveredUrl != null) {
      print('✅ Discovered Backend Server at: $discoveredUrl');
      AppConfig.apiBaseUrl = 'http://$discoveredUrl';
    } else {
      print('⚠️ Discovery timed out, using fallback IP: ${AppConfig.apiBaseUrl}');
    }
  } else {
    print('🌐 Web mode — API base URL: ${AppConfig.apiBaseUrl}');
  }

  await AuthService.init();
  runApp(const LunchifyApp());
}

class LunchifyApp extends StatelessWidget {
  const LunchifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lunchify SJVN',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        fontFamily: 'Typewriter',
        scaffoldBackgroundColor: kBgColor,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kNavy,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        primaryColor: kNavy,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: kSubtle,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBorder, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBlue, width: 1.5),
          ),
        ),
      ),

      darkTheme: ThemeData.light(),
      themeMode: ThemeMode.light,

      home: const IntroPage(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/auth': (context) => const AuthWrapper(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    if (AuthService.token == null || AuthService.user == null) {
      return const LoginPage();
    }

    return AuthService.isAdmin
        ? AdminPage(
      adminName: AuthService.name,
      jwtToken: AuthService.token!,
    )
        : LunchifyHomePage(
      employeeName: AuthService.name,
      employeeId: AuthService.employeeId,
    );
  }
}
