import 'package:flutter/material.dart';
import 'package:teleapp/screens/auth/login_screen.dart';
// import 'package:teleapp/screens/biometric_login_screen.dart';
// import 'package:teleapp/utils/auth_storage.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); // 👈 Thêm dòng này

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // final isLoggedIn = await AuthStorage.isLoggedIn();

  runApp(MyApp(
    // initialScreen: isLoggedIn ? const BiometricLoginScreen() : const LoginScreen(),
    initialScreen: const LoginScreen(),
  ));
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeleMedicine',
      navigatorKey: navigatorKey, // 👈 Thêm dòng này để ApiService redirect được
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        fontFamily: 'NotoSans',
      ),
      home: initialScreen,
    );
  }
}
