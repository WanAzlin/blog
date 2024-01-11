import 'package:blog/models/post.dart';
import 'package:flutter/material.dart';

class BlogPost extends StatelessWidget {
  final Post post;

  const BlogPost({
    required this.post,
    super.key,
  });
  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: Text(post.body),
    );
  }
}
