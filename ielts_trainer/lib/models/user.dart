class User {
  final int? id;
  final String? username; // В базе это email
  final String? nickname;
  final String? avatarUrl; // В базе это avatar_url
  final double? lastScore; // Новое поле, которое мы добавили в SQL

  User({this.id, this.username, this.nickname, this.avatarUrl, this.lastScore});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      // В базе колонка называется 'email', мапим её в username
      username: json['email'],
      nickname: json['nickname'],
      // В базе колонка 'avatar_url'
      avatarUrl: json['avatar_url'],

      // Читаем балл (если он есть)
      lastScore: json['last_score'] != null
          ? (json['last_score'] as num).toDouble()
          : null,
    );
  }
}
