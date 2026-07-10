import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';

/// Admin screen to review and approve/reject EVC Plus payment
/// submissions. Approving instantly activates 30 days of Premium
/// for that user — no separate merchant API needed.
class AdminPaymentsScreen extends StatelessWidget {
  const AdminPaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fs = FirestoreService();
    return Scaffold(
      appBar: AppBar(title: const Text('Xaqiijinta Lacagaha')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: fs.streamPendingPayments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final payments = snapshot.data!;
          if (payments.isEmpty) {
            return const Center(child: Text('Ma jiraan lacago sugaya xaqiijin.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: payments.length,
            itemBuilder: (context, i) {
              final p = payments[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Qiimaha: \$${p['amountUsd']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('Lambarka Direyay: ${p['senderPhone']}'),
                      Text('Transaction ID: ${p['transactionId']}'),
                      Text('UID: ${p['uid']}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => fs.approvePayment(p['id'], p['uid']),
                              child: const Text('Ansixi (Approve)'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                              onPressed: () => fs.rejectPayment(p['id']),
                              child: const Text('Diid (Reject)'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
