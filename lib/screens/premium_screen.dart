import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/payment_service.dart';
import '../theme/app_theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _payments = PaymentService();
  final _phoneCtrl = TextEditingController();
  double _price = 0.60;
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _loadPrice();
  }

  Future<void> _loadPrice() async {
    try {
      final p = await _payments.getCurrentSubscriptionPrice();
      setState(() => _price = p);
    } catch (_) {
      // fallback to default $0.60 if function unavailable in dev
    }
  }

  Future<void> _payWithEvc() async {
    setState(() { _loading = true; _message = null; });
    try {
      final result = await _payments.payWithEvcPlus(
        phoneNumber: _phoneCtrl.text.trim(),
        amountUsd: _price,
      );
      setState(() => _message = result['message'] ?? 'Codsigii lacag-bixinta waa la diray. Fadlan xaqiiji SMS-kaaga.');
    } catch (e) {
      setState(() => _message = 'Khalad ayaa dhacay lacag-bixinta EVC Plus.');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _payWithUsdt() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() { _loading = true; _message = null; });
    try {
      final result = await _payments.createUsdtPaymentIntent(uid: uid, amountUsd: _price);
      final address = result['depositAddress'] ?? '—';
      setState(() => _message = 'U dir $_price USDT (TRC20) ilaa: $address\nKadib xaqiijinta way dhici doontaa otomaatig ahaan.');
    } catch (e) {
      setState(() => _message = 'Khalad ayaa dhacay USDT payment-ka.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: AppColors.darkSurface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.workspace_premium, color: AppColors.primary, size: 48),
                    const SizedBox(height: 8),
                    Text('\$${_price.toStringAsFixed(2)} / bishii', style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Daawo dhammaan ciyaaraha live-ka ah oo aan xayiraan lahayn', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Dooro habka lacag-bixinta:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Lambarka EVC Plus (+252...)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _loading ? null : _payWithEvc,
              icon: const Icon(Icons.phone_android),
              label: const Text('Ku bixi EVC Plus'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loading ? null : _payWithUsdt,
              icon: const Icon(Icons.currency_bitcoin),
              label: const Text('Ku bixi USDT (TRC20)'),
            ),
            if (_loading) const Padding(padding: EdgeInsets.only(top: 16), child: Center(child: CircularProgressIndicator())),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primary)),
              ),
          ],
        ),
      ),
    );
  }
}
