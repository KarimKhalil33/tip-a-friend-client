import 'package:flutter/material.dart';
import 'package:tip_a_friend_client/screens/login_screen.dart';
import 'package:tip_a_friend_client/services/auth_service.dart';
import 'package:tip_a_friend_client/screens/home_feed_screen.dart';

void main() {
  runApp(const TipAFriendApp());
}

class TipAFriendApp extends StatelessWidget {
  const TipAFriendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tip A Friend',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const StartupScreen(),
    );
  }
}

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  bool _checkingAuth = true;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    setState(() {
      _loggedIn = isLoggedIn;
      _checkingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return _loggedIn ? const HomeFeedScreen() : const LoginScreen();
  }
}
