import 'package:flutter/material.dart';

import 'splashscreen.dart';
import 'view/kamera_spot_line.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (ctx) => const SplashScreen(),
        "/kamera": (ctx) => const Kamera(),
      },
      
    );
  }
}
