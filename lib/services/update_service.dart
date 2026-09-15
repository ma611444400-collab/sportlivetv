import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateInfo {
  final String versionName;
  final int versionCode;
  final String releaseNotes;
  final String downloadUrl;

  const UpdateInfo({
    required this.versionName,
    required this.versionCode,
    required this.releaseNotes,
    required this.downloadUrl,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) => UpdateInfo(
        versionName: json['versionName'] as String,
        versionCode: (json['versionCode'] as num).toInt(),
        releaseNotes: json['releaseNotes'] as String? ?? '',
        downloadUrl: json['downloadUrl'] as String,
      );
}

class UpdateService {
  static const manifestUrl =
      'https://raw.githubusercontent.com/ma611444400-collab/sportlivetv/main/update_manifest.json';

  static Future<UpdateInfo?> check() async {
    try {
      final response = await http.get(Uri.parse(manifestUrl)).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final info = UpdateInfo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      final package = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(package.buildNumber) ?? 1;
      return info.versionCode > currentCode ? info : null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> checkAndPrompt(BuildContext context) async {
    final info = await check();
    if (!context.mounted || info == null) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update cusub ayaa jira'),
        content: Text('${info.versionName}\n\n${info.releaseNotes}\n\nRiix “Soo dejiso” si aad u furto download-ka APK-ga.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hadda maya')),
          FilledButton(
            onPressed: () async {
              final uri = Uri.parse(info.downloadUrl);
              if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Soo dejiso'),
          ),
        ],
      ),
    );
  }
}
