import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Icon(Icons.verified_user, color: AppColors.primary, size: 48),
          SizedBox(height: 12),
          Text('SportLiveTV — Privacy Policy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Waxaa maamula sahalcrypt.com', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 24),
          _Section(title: 'Xogta aan ururino', body: 'App-ku wuxuu kaydin karaa magaca, email-ka ama lambarka telefoonka aad ku isticmaasho login-ka, iyo xogta ciyaaraha aad favorites ka dhigato. Xogtan waxaa loo isticmaalaa oo keliya account-ka, favorites-ka iyo adeegga app-ka.'),
          _Section(title: 'Live scores iyo API', body: 'Live scores-ka waxaa laga keenaa API-Football/API-Sports. App-ku wuxuu diraa codsiyada xogta ciyaaraha, laakiin ma diro password-kaaga ama xog gaar ah provider-ka.'),
          _Section(title: 'Streaming', body: 'Link kasta oo streaming ah waa inuu noqdaa mid admin-ku leeyahay oggolaansho uu ku isticmaalo. App-ku ma martigeliyo ama ma qaybinayo content aan ruqsad lahayn.'),
          _Section(title: 'Xayeysiis iyo lacag-bixin', body: 'Haddii lacag-bixin ama premium la isticmaalo, caddeynta lacag-bixinta waxaa loo isticmaalaa xaqiijinta adeegga oo keliya. Ha ku darin xog kaarka bangiga meel aan loogu talagelin.'),
          _Section(title: 'Amniga iyo tirtirka xogta', body: 'Waxaan isticmaalnaa Firebase iyo xeerar access-control ah. Waxaad codsan kartaa in account-kaaga iyo xogtiisa la tirtiro adigoo la xiriiraya sahalcrypt.com.'),
          _Section(title: 'Isbeddelada policy-ga', body: 'Policy-gan waa la cusboonaysiin karaa marka app-ku helo adeegyo cusub. Taariikhda ugu dambaysa: 18 Sebtembar 2026.'),
          SizedBox(height: 20),
          Center(child: Text('sahalcrypt.com', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String body;
  const _Section({required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 7),
          Text(body, style: const TextStyle(height: 1.45, color: Colors.grey)),
        ]),
      );
}
