import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import 'auth/login_screen.dart';
import 'admin_matches_screen.dart';
import 'admin_payments_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final fs = FirestoreService();
    final auth = AuthService();

    return StreamBuilder(
      stream: uid != null ? fs.streamUser(uid) : null,
      builder: (context, snapshot) {
        final user = snapshot.data;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CircleAvatar(radius: 40, child: Text(user?.displayName.isNotEmpty == true ? user!.displayName[0] : '?')),
            const SizedBox(height: 12),
            Center(child: Text(user?.displayName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            Center(child: Text(user?.email ?? user?.phone ?? '', style: const TextStyle(color: Colors.grey))),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(user?.hasActivePremium == true ? Icons.workspace_premium : Icons.lock_outline),
              title: const Text('Xaaladda Premium'),
              subtitle: Text(user?.hasActivePremium == true ? 'Firfircoon' : 'Ma jiro'),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Luqadda'),
              trailing: DropdownButton<String>(
                value: user?.preferredLanguage ?? 'so',
                items: const [
                  DropdownMenuItem(value: 'so', child: Text('Soomaali')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'ar', child: Text('العربية')),
                ],
                onChanged: (v) {
                  if (uid != null && v != null) fs.updateLanguage(uid, v);
                },
              ),
            ),
            Card(
              color: AppColors.primary,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings, color: Colors.black),
                title: const Text('ADMIN — Maamul Ciyaaraha', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminMatchesScreen()),
                ),
              ),
            ),
            Card(
              color: AppColors.secondary,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.payments, color: Colors.white),
                title: const Text('ADMIN — Xaqiijinta Lacagaha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminPaymentsScreen()),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Ka bax', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await auth.signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
