import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/menu_page.dart';
import 'pages/coupon_status_page.dart';
import 'pages/buy_lunch_page.dart';

void main() {
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
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFCDDFF0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A2E6E),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login':   (context) => const LoginScreen(),
        '/home':    (context) => const HomeScreen(),
        '/menu':    (context) => const TodayMenuPage(),
        '/coupons':   (context) => const CouponStatusPage(),
        '/buy-lunch': (context) => const BuyLunchPage(),
      },
    );
  }
}
