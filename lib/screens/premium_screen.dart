import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _fs = FirestoreService();
  final _senderPhoneCtrl = TextEditingController();
  final _txnIdCtrl = TextEditingController();
  final double _price = 0.60;
  static const String evcReceiverNumber = '+252611444400';
  bool _submitting = false;
  String? _message;

  Future<void> _submit() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    if (_senderPhoneCtrl.text.trim().isEmpty || _txnIdCtrl.text.trim().isEmpty) {
      setState(() => _message = 'Fadlan buuxi labada goob.');
      return;
    }
    setState(() { _submitting = true; _message = null; });
    try {
      await _fs.submitPaymentRequest(
        uid: uid,
        senderPhone: _senderPhoneCtrl.text.trim(),
        transactionId: _txnIdCtrl.text.trim(),
        amountUsd: _price,
      );
      setState(() {
        _message = 'Codsigaaga waa la diray! Admin-ku wuu xaqiijin doonaa lacagta, kadibna Premium-kaagu si otomaatig ah ayuu u furmi doonaa.';
        _senderPhoneCtrl.clear();
        _txnIdCtrl.clear();
      });
    } catch (e) {
      setState(() => _message = 'Khalad ayaa dhacay. Isku day mar kale.');
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Premium')),
      body: SingleChildScrollView(
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
                    const Text('Daawo dhammaan ciyaaraha live-ka ah', textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              color: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tallaabo 1: U Dir Lacagta', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      'U dir \$${_price.toStringAsFixed(2)} (EVC Plus) lambarkan:',
                      style: const TextStyle(color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      evcReceiverNumber,
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Tallaabo 2: Geli Xaqiijinta', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 8),
            const Text(
              'Kadib marka aad dirto lacagta, geli lambarkaaga & Transaction ID-ga (ka soo baxa SMS xaqiijinta EVC Plus):',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senderPhoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Lambarkaaga EVC Plus (aad ka dirtay)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _txnIdCtrl,
              decoration: const InputDecoration(
                labelText: 'Transaction ID / Reference',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Dir Xaqiijinta'),
            ),
            if (_message != null) ...[
              const SizedBox(height: 16),
              Text(_message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.primary)),
            ],
          ],
        ),
      ),
    );
  }
}
