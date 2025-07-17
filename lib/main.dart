// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/salah_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'services/prayer_time_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  await Hive.openBox('salah_tracker');
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const SalahApp());
}

class SalahApp extends StatelessWidget {
  const SalahApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SalahProvider(),
      child: MaterialApp(
        title: 'Salah Tracker',
        theme: ThemeData(
          primarySwatch: Colors.green,
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        ),
        home: const HomeScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}