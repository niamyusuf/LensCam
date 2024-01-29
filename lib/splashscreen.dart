import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen.gif(
      backgroundColor: Colors.grey[100],
      useImmersiveMode: true,
      gifPath: 'assets/splashscreen/splash.gif',
      gifWidth: 269,
      gifHeight: 474,
      asyncNavigationCallback: () async {
        await Future.delayed(const Duration(seconds: 3));
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/kamera');
          // return const Kamera();
          // GoRouter.of(context).goNamed("home");
          // context.goNamed('home');
        }
      },
    );
  }
}
