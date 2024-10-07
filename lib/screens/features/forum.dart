import 'package:flutter/material.dart';
import 'package:kekomarz/screens/features/add-post-to-forum.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forum'),
      ),
      body: const Center(
        child: Text('Forum posts will be displayed here.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the AddPostToForumScreen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPostToForumScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Add Post',
      ),
    );
  }
}
