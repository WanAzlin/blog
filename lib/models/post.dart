class Post {
  final int userId;
  final int id;
  final String title;
  final String body;

  const Post({
    required this.userId,
    required this.id,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'userId': int userId,
        'id': int id,
        'title': String title,
        'body': String body,
      } =>
        Post(
          userId: userId,
          id: id,
          title: title,
          body: body,
        ),
      _ => const Post(
          userId: 0,
          id: 0,
          title: '',
          body: '',
        ),
    };
  }
}
