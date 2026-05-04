class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final List<int> watchHistory;
  final List<int> watchlist;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.watchHistory = const [],
    this.watchlist = const [],
    this.createdAt,
  });

  String get initials {
    if (displayName != null && displayName!.isNotEmpty) {
      final parts = displayName!.split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return displayName![0].toUpperCase();
    }
    return email.isNotEmpty ? email[0].toUpperCase() : 'V';
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      watchHistory: (data['watchHistory'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      watchlist: (data['watchlist'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'watchHistory': watchHistory,
        'watchlist': watchlist,
      };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    List<int>? watchHistory,
    List<int>? watchlist,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      watchHistory: watchHistory ?? this.watchHistory,
      watchlist: watchlist ?? this.watchlist,
      createdAt: createdAt,
    );
  }
}
