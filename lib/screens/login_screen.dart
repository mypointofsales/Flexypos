import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/auth_services.dart';
import 'sales_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String _error = '';

  void _login() async {
    final user = await AuthService().login(
      _emailController.text,
      _passwordController.text,
    );

    if (user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SalesScreen()),
      );
    } else {
      setState(() {
        _error = 'login_failed'.tr();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A192F),
            boxShadow: [
              BoxShadow(
                color: Colors.blueAccent.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'sign_in'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('email'.tr(), style: TextStyle(color: Color(0xFF0A192F))),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                isDense: true,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0A192F)),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0A192F), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('password'.tr(), style: TextStyle(color: Color(0xFF0A192F))),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                isDense: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00BFFF), Color(0xFF0080FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.6),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
                borderRadius: BorderRadius.circular(8),
              ),
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  side: const BorderSide(color: Colors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: Text(
                  'sign_in'.tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  // TODO: Aksi lupa password
                },
                child: Text(
                  'forgot_password'.tr(),
                  style: TextStyle(color: Color(0xFF0A192F)),
                ),
              ),
            ),
            if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
