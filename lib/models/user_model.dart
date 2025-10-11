class UserModel {
  final String name;
  final String? avatarUrl;
  final String? currentSong;

  UserModel({
    required this.name,
    this.avatarUrl,
    this.currentSong,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] ?? 'Unknown',
      avatarUrl: json['avatarUrl'],
      currentSong: json['currentSong'],
    );
  }
}
