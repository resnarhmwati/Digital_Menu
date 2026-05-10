import 'package:cafe_menu_digital/screens/admin/dashboard_screen.dart';
import 'package:cafe_menu_digital/screens/admin/login_screen.dart';
import 'package:cafe_menu_digital/services/auth_services.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController _logoController;
  late Animation<double> _fade;
  late Animation<double> _scale;

  bool _showLogo = false;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fade = CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.2, 1, curve: Curves.easeOut),
    );

    _scale = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOutCubic,
      ),
    );

    _start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage("assets/splash_bg.png"), context);
  }

  Future<void> _start() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    setState(() => _showLogo = true);
    _logoController.forward();

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    _goNext();
  }

  void _goNext() {
    final authService = AuthService();
    final user = authService.currentUser;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => user != null
            ? const DashboardScreen()
            : const LoginScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background foto
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/splash.png"),
                fit: BoxFit.fill,
              ),
            ),
          ),

          // Logo foto dengan animasi
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showLogo
                  ? FadeTransition(
                      opacity: _fade,
                      child: ScaleTransition(
                        scale: _scale,
                        child: Image.asset(
                          "assets/arseven_logo.png",
                          width: 300,
                        ),
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}