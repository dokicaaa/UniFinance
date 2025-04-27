import 'package:banking4students/providers/budget_provider.dart';
import 'package:banking4students/providers/monthly_report_provider.dart';
import 'package:banking4students/providers/savings_challenge_provider.dart';
import 'package:banking4students/providers/spending_alternatives_provider.dart';
import 'package:banking4students/providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/database_provider.dart';
import 'services/auth/auth_gate.dart';
import 'services/auth/auth_service.dart';
import 'providers/navigation_provider.dart';
import 'theme/themes.dart';
import 'pages/onboarding_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final prefs = await SharedPreferences.getInstance();

  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;


  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()),
        ChangeNotifierProvider(
          create: (_) => WeeklyPlanProvider(),
        ), // ✅ FIX: Use ChangeNotifierProvider
        ChangeNotifierProvider(create: (_) => SpendingAlternativesProvider()),
        ChangeNotifierProvider(create: (_) => SavingsChallengeProvider()),
        ChangeNotifierProvider(create: (_) => BudgetProvider()),
        ChangeNotifierProvider(create: (_) => MonthlyReportProvider()),
      ],
      child: MyApp(seenOnboarding: false),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool seenOnboarding;

  const MyApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking4Students',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: seenOnboarding ? AuthGate() : OnboardingPage(),
    );
  }
}
