import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'signup_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _usePhone = false;
  bool _loading = false;
  String? _error;

  Future<void> _loginEmail() async {
    setState(() { _loading = true; _error = null; });
    try {
      await _auth.loginWithEmail(email: _emailCtrl.text.trim(), password: _passCtrl.text);
      if (mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _error = 'Email ama password-ku waa qalad');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _startPhoneLogin() async {
    setState(() { _loading = true; _error = null; });
    await _auth.startPhoneVerification(
      phoneNumber: _phoneCtrl.text.trim(),
      onCodeSent: (verificationId) {
        setState(() => _loading = false);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => OtpScreen(verificationId: verificationId),
        ));
      },
      onError: (err) {
        setState(() { _loading = false; _error = err; });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.sports_soccer, color: AppColors.primary, size: 60),
              const SizedBox(height: 16),
              const Text('Ku soo dhawoow', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Gal si aad u aragto jadwalka & live scores-ka', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              ToggleButtons(
                isSelected: [!_usePhone, _usePhone],
                onPressed: (i) => setState(() => _usePhone = i == 1),
                borderRadius: BorderRadius.circular(12),
                children: const [
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Email')),
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Text('Phone')),
                ],
              ),
              const SizedBox(height: 24),
              if (!_usePhone) ...[
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                ),
              ] else ...[
                TextField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Lambarka Telefoonka (+252...)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : (_usePhone ? _startPhoneLogin : _loginEmail),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Gal'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SignupScreen())),
                child: const Text('Ma lihid account? Isdiiwaangeli'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
