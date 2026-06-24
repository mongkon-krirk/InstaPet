class UserModel {
  final String documentId;
  final String username;
  final String displayName;
  final String bio;
  final String? avatarUrl;
  final bool isPrivate;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isFollowing;
  final bool isMe;
  final String? email;
  final bool profileCompleted;

  const UserModel({
    required this.documentId,
    required this.username,
    required this.displayName,
    this.bio = '',
    this.avatarUrl,
    this.isPrivate = false,
    this.postsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
    this.isMe = false,
    this.email,
    this.profileCompleted = false,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        documentId: json['documentId'] as String? ?? '',
        username: json['username'] as String? ?? '',
        displayName: json['displayName'] as String? ?? json['username'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        isPrivate: json['isPrivate'] as bool? ?? false,
        postsCount: json['postsCount'] as int? ?? 0,
        followersCount: json['followersCount'] as int? ?? 0,
        followingCount: json['followingCount'] as int? ?? 0,
        isFollowing: json['isFollowing'] as bool? ?? false,
        isMe: json['isMe'] as bool? ?? false,
        email: json['email'] as String?,
        profileCompleted: json['profileCompleted'] as bool? ?? false,
      );

  UserModel copyWith({
    String? displayName,
    String? bio,
    String? avatarUrl,
    bool? isPrivate,
    int? postsCount,
    int? followersCount,
    int? followingCount,
    bool? isFollowing,
    String? username,
  }) {
    return UserModel(
      documentId: documentId,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isPrivate: isPrivate ?? this.isPrivate,
      postsCount: postsCount ?? this.postsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
      isMe: isMe,
      email: email,
      profileCompleted: profileCompleted,
    );
  }
}
