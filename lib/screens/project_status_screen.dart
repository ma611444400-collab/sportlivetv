import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProjectStatusScreen extends StatelessWidget {
  const ProjectStatusScreen({super.key});

  static const _items = [
    ('Login iyo Signup', 'La dhammeeyay', true),
    ('Home iyo categories', 'La dhammeeyay', true),
    ('Live demo matches', 'La dhammeeyay', true),
    ('Jadwalka ciyaaraha', 'La dhammeeyay', true),
    ('Search iyo Favorites', 'La dhammeeyay', true),
    ('Video player HD/SD', 'La dhammeeyay', true),
    ('Premium access', 'La dhammeeyay', true),
    ('Payment security', 'La dhammeeyay', true),
    ('Admin match management', 'La dhammeeyay', true),
    ('Firebase production deploy', 'Weli socda', false),
    ('Real licensed live feeds', 'Waxa ka dhiman URLs rukhsad leh', false),
    ('Final release APK', 'Waxaa la samaynayaa marka code-ku dhamaado', false),
  ];

  @override
  Widget build(BuildContext context) {
    final completed = _items.where((item) => item.$3).length;
    final progress = completed / _items.length;
    return Scaffold(
      appBar: AppBar(title: const Text('Horumarka Mashruuca')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SportLiveTV', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('$completed / ${_items.length} qaybood waa la dhammeeyay', style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(value: progress, minHeight: 10, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).round()}% diyaar', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Qaybaha mashruuca', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._items.map((item) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(item.$3 ? Icons.check_circle : Icons.pending, color: item.$3 ? AppColors.primary : Colors.orange),
                  title: Text(item.$1),
                  subtitle: Text(item.$2),
                  trailing: item.$3 ? const Text('OK', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)) : const Text('SOCDA'),
                ),
              )),
          const SizedBox(height: 12),
          const Text('Fiiro gaar ah: APK cusub lama samaynayo inta source code-ka la horumarinayo. Marka qaybaha muhiimka ah dhammaadaan, hal APK final ah ayaa la build-gareyn doonaa.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
