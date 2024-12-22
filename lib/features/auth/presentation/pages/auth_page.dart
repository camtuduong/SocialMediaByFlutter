/*

Auth Page - This page determines whether to show the login or register page

*/

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:socialmediaapp/features/auth/presentation/pages/login_page.dart';
import 'package:socialmediaapp/features/auth/presentation/pages/register_page.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(togglePages: togglePages);
    } else {
      return RegisterPage(togglePages: togglePages);
    }
  }
}
