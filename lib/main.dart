import 'package:flutter/material.dart';
import 'package:food_tracker/models/food_item.dart';
import 'package:food_tracker/screens/home_screen.dart';
import 'package:food_tracker/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(FoodItemAdapter());
  await Hive.openBox<FoodItem>('food_items');

  final notificationService = NotificationService();
  await notificationService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen());
  }
}



