// 📄 lib/screens/login_register_wrapper.dart
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';


class LoginRegisterWrapper extends StatefulWidget {
  const LoginRegisterWrapper({super.key});

  @override
  State<LoginRegisterWrapper> createState() => _LoginRegisterWrapperState();
}

class _LoginRegisterWrapperState extends State<LoginRegisterWrapper> {
  final PageController _pageController = PageController();

  void goToRegister() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void goToLogin() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // desactivar swipe manual si prefieres
        children: [
          LoginScreen(onSwitch: goToRegister),
          RegisterScreen(onSwitch: goToLogin),
        ],
      ),
    );
  }
}
