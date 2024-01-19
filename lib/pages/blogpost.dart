import 'dart:convert';

import 'package:blog/models/post.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

SnackBar _snackBar(String message) => SnackBar(
      content: Text(message),
    );

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

late TextEditingController _titleInputController;
late TextEditingController _bodyInputController;
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

class PostBody extends StatefulWidget {
  final Post post;
  const PostBody({required this.post, super.key});

  @override
  State<PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends State<PostBody> {
  Future<Post>? futurePost;

  @override
  void initState() {
    super.initState();
    _titleInputController = TextEditingController();
    _bodyInputController = TextEditingController();
    futurePost = fetchPost();
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

  // UpdatePost
  // make a http request to server
  // pass the title and body ke dalam body section of http request.
  // check the status code == 200
  // return Post();
  // else
  // Throw error.

  // http.post() <- create new data.
  Future<Post> updatePost(int id) async {
    final response = await http.put(
      Uri.parse('https://jsonplaceholder.typicode.com/posts/$id'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'title': _titleInputController.text,
        'body': _bodyInputController.text,
      }),
    );

    if (response.statusCode == 200) {
      return Post.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to update post');
    }
  }

  // Update Post
  // http.put() <-- Update a resource.
  // http
  // - Header
  // - 'Content-Type': 'application/json; charset=UTF-8',
  // - Body
  // - title
  // - body
  // - url = 'https://jsonplaceholder.typicode.com/posts/$id

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
            _bodyInputController.value =
                TextEditingValue(text: snapshot.data?.body ?? '');
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          controller: _titleInputController,
                          decoration: const InputDecoration(
                            hintText: 'Blog Title Here',
                            label: Text('Blog Title'),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        TextFormField(
                          controller: _bodyInputController,
                          decoration: const InputDecoration(
                            hintText: 'Blog Body Here',
                            label: Text('Blog Body'),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate will return true if the form is valid, or false if
                              // the form is invalid.
                              if (_formKey.currentState!.validate()) {
                                // Process data.
                                // UpdatePost
                                // Display update message in snackbar
                                setState(() {
                                  futurePost = updatePost(snapshot.data!.id);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(_snackBar('updated'));
                                });
                              }
                            },
                            child: const Text('Update'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
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
