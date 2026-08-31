import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:need_mobile_app/firebase_options.dart';
import 'package:need_mobile_app/providers/auth_provider.dart';
import 'package:need_mobile_app/providers/booking_provider.dart';
import 'package:need_mobile_app/providers/business_provider.dart';
import 'package:need_mobile_app/providers/category_provider.dart';
import 'package:need_mobile_app/providers/employee_provider.dart';
import 'package:need_mobile_app/providers/review_provider.dart';
import 'package:need_mobile_app/providers/term_provider.dart';
import 'package:need_mobile_app/providers/user_provider.dart';
import 'package:need_mobile_app/providers/work_schedule_provider.dart';
import 'package:need_mobile_app/screens/main_shell.dart';
import 'package:need_mobile_app/services/auth_service.dart';
import 'package:provider/provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider(authService: AuthService())),
          ChangeNotifierProvider(create: (_) => BusinessProvider()),
          ChangeNotifierProvider(create: (_) => BookingProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => EmployeeProvider()),
          ChangeNotifierProvider(create: (_) => ReviewProvider()),
          ChangeNotifierProvider(create: (_) => WorkScheduleProvider()),
          ChangeNotifierProvider(create: (_) => TermProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
        ],
        child: MaterialApp(
          title: 'Need',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorSchemeSeed: Colors.teal,
            useMaterial3: true,
          ),
          home: const MainShell(),
        ),
    );
  }
}
