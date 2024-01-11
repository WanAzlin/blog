import 'dart:convert';

import 'package:blog/models/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

SnackBar _snackBar(String message) => SnackBar(
      content: Text(message),
    );

late TextEditingController _titleInputController;

class PostScreen extends StatelessWidget {
  final Post post;
  const PostScreen({required this.post, super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Home Screen'),
        ),
        body: PostBody(post: post),
      );
}

class PostBody extends StatefulWidget {
  final Post post;
  const PostBody({required this.post, super.key});

  @override
  State<PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> {
  late Future<Post> futurePost;

  @override
  void initState() {
    super.initState();
    futurePost = fetchPost();
    _titleInputController = TextEditingController();
  }

  @override
  void dispose() {
    _titleInputController.dispose();
    super.dispose();
  }

  Future<Post> fetchPost() async {
    final response = await http.get(Uri.parse(
        'https://jsonplaceholder.typicode.com/posts/${widget.post.id}'));

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load post');
    }
  }

  Future<Post> deletePost(int id) async {
    final response = await http.delete(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to delete post.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
          child: FutureBuilder<Post>(
        future: futurePost,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _titleInputController.value =
                TextEditingValue(text: snapshot.data?.title ?? '');
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(snapshot.data?.id == 0 ? 'Deleted' : ''),
                  MyCustomInput(
                    title: 'Title',
                    textEditingController: _titleInputController,
                  ),
                  Text(snapshot.data?.body ?? ''),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Update'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              futurePost = deletePost(snapshot.data!.id);
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(_snackBar('Deleted'));
                            });
                          },
                          child: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(
              child: SizedBox(child: CircularProgressIndicator()));
        },
      )),
    ]);
  }
}

class MyCustomInput extends StatelessWidget {
  final String title;
  final TextEditingController textEditingController;
  const MyCustomInput(
      {required this.textEditingController, required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: TextField(
            controller: textEditingController,
            decoration: InputDecoration(
              labelText: title,
              border: const OutlineInputBorder(),
              hintText: 'Enter a search term',
            ),
          ),
        ),
      ],
    );
  }
}
