class AppUser {
  final String uid;
  final String? email;
  final String? phone;
  final String displayName;
  final bool isPremium;
  final DateTime? premiumExpiresAt;
  final bool isBlocked;
  final String preferredLanguage; // 'so', 'en', 'ar'
  final List<String> favoriteTeamIds;
  final DateTime createdAt;

  AppUser({
    required this.uid,
    this.email,
    this.phone,
    required this.displayName,
    this.isPremium = false,
    this.premiumExpiresAt,
    this.isBlocked = false,
    this.preferredLanguage = 'so',
    this.favoriteTeamIds = const [],
    required this.createdAt,
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> map) {
    return AppUser(
      uid: uid,
      email: map['email'],
      phone: map['phone'],
      displayName: map['displayName'] ?? '',
      isPremium: map['isPremium'] ?? false,
      premiumExpiresAt: map['premiumExpiresAt'] != null
          ? DateTime.tryParse(map['premiumExpiresAt'])
          : null,
      isBlocked: map['isBlocked'] ?? false,
      preferredLanguage: map['preferredLanguage'] ?? 'so',
      favoriteTeamIds: List<String>.from(map['favoriteTeamIds'] ?? []),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'phone': phone,
      'displayName': displayName,
      'isPremium': isPremium,
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'isBlocked': isBlocked,
      'preferredLanguage': preferredLanguage,
      'favoriteTeamIds': favoriteTeamIds,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get hasActivePremium =>
      isPremium && (premiumExpiresAt == null || premiumExpiresAt!.isAfter(DateTime.now()));
}
