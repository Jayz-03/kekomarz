import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/features/add-post-to-forum.dart';
import 'package:timeago/timeago.dart' as timeago;

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  _ForumScreenState createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  final DatabaseReference _forumRef =
      FirebaseDatabase.instance.ref().child('Forum');
  final DatabaseReference _usersRef =
      FirebaseDatabase.instance.ref().child('users');
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        title: Text('Forum', style: GoogleFonts.robotoCondensed()),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Image.asset(
              'assets/images/kekomarz-logo.png',
              width: 120,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _forumRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            Map<dynamic, dynamic> usersPosts =
                snapshot.data!.snapshot.value as Map<dynamic, dynamic>? ?? {};
            List<Map<dynamic, dynamic>> allPosts = [];

            usersPosts.forEach((userId, userPosts) {
              if (userPosts is Map) {
                userPosts.forEach((postId, postData) {
                  allPosts.add({
                    'userId': userId,
                    'postId': postId,
                    'postData': postData,
                  });
                });
              }
            });

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                String postId = allPosts[index]['postId'];
                String userId = allPosts[index]['userId'];
                Map<dynamic, dynamic> post = allPosts[index]['postData'];
                return _buildPostCard(postId, post, userId);
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
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

  Future<Map<String, String>> _getUserInfo(String userId) async {
    DatabaseEvent snapshot = await _usersRef.child(userId).once();
    Map<dynamic, dynamic>? userData =
        snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (userData != null) {
      String firstName = userData['firstName'] ?? 'Unknown';
      String lastName = userData['lastName'] ?? 'Unknown';
      return {'firstName': firstName, 'lastName': lastName};
    }
    return {'firstName': 'Unknown', 'lastName': 'Unknown'};
  }

  Widget _buildPostCard(
      String postId, Map<dynamic, dynamic> post, String userId) {
    Map<dynamic, dynamic> likesMap = post['likes'] ?? {};
    Map<dynamic, dynamic> dislikesMap = post['dislikes'] ?? {};
    Map<dynamic, dynamic> commentsMap = post['comments'] ?? {};
    String caption = post['caption'] ?? 'No caption available';
    List<dynamic> images = post['images'] ?? [];
    String timestamp = post['timestamp'] ?? DateTime.now().toString();

    List<dynamic> likes = likesMap.keys.toList();
    List<dynamic> dislikes = dislikesMap.keys.toList();
    List<Map<dynamic, dynamic>> comments = commentsMap.entries
        .map((e) => {'commentId': e.key, 'commentData': e.value})
        .toList();

    bool userLiked = likes.contains(_currentUser?.uid);
    bool userDisliked = dislikes.contains(_currentUser?.uid);

    DateTime postTime = DateTime.parse(timestamp);

    return FutureBuilder<Map<String, String>>(
      future: _getUserInfo(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        String userFullName =
            '${snapshot.data?['firstName'] ?? ''} ${snapshot.data?['lastName'] ?? ''}';

        return Card(
          elevation: 4,
          color: Colors.white,
          margin: const EdgeInsets.all(10),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(caption, style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                Text(
                  '$userFullName • ${timeago.format(postTime)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),
                images.isNotEmpty
                    ? SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Image.network(images[index],
                                  width: 100, height: 100, fit: BoxFit.cover),
                            );
                          },
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(userLiked
                          ? Icons.thumb_up
                          : Icons.thumb_up_alt_outlined),
                      onPressed: () => _toggleLike(postId, userLiked),
                    ),
                    Text('${likes.length} Likes'),
                    IconButton(
                      icon: Icon(userDisliked
                          ? Icons.thumb_down
                          : Icons.thumb_down_alt_outlined),
                      onPressed: () => _toggleDislike(postId, userDisliked),
                    ),
                    Text('${dislikes.length} Dislikes'),
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () => _showComments(postId, comments),
                    ),
                    Text('${comments.length} Comments'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleLike(String postId, bool userLiked) async {
    if (_currentUser == null) return;

    DatabaseReference postRef =
        _forumRef.child(_currentUser!.uid).child(postId);

    if (userLiked) {
      // User already liked, remove the like
      await postRef.child('likes/${_currentUser!.uid}').remove();
    } else {
      // User has not liked, add the like
      await postRef.child('likes/${_currentUser!.uid}').set(true);
    }
  }

  void _toggleDislike(String postId, bool userDisliked) async {
    if (_currentUser == null) return;

    DatabaseReference postRef =
        _forumRef.child(_currentUser!.uid).child(postId);

    if (userDisliked) {
      // User already disliked, remove the dislike
      await postRef.child('dislikes/${_currentUser!.uid}').remove();
    } else {
      // User has not disliked, add the dislike
      await postRef.child('dislikes/${_currentUser!.uid}').set(true);
    }
  }

  void _showComments(String postId, List<Map<dynamic, dynamic>> comments) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  Map<dynamic, dynamic> comment =
                      comments[index]['commentData'];
                  String commentTimestamp =
                      comment['timestamp'] ?? DateTime.now().toString();
                  DateTime commentTime = DateTime.parse(commentTimestamp);
                  String commentUserId = comment['userId'] ?? '';

                  return FutureBuilder<Map<String, String>>(
                    future: _getUserInfo(commentUserId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          title: Text('Loading...'),
                        );
                      }

                      String commentUserFullName =
                          '${snapshot.data?['firstName'] ?? ''} ${snapshot.data?['lastName'] ?? ''}';

                      return ListTile(
                        title: Text(comment['message']),
                        subtitle: Text(
                          '$commentUserFullName • ${timeago.format(commentTime)}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration(
                  labelText: 'Add a comment...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (text) => _addComment(postId, text),
              ),
            ),
          ],
        );
      },
    );
  }

  void _addComment(String postId, String commentText) async {
    if (_currentUser == null) return;

    DatabaseReference commentRef = _forumRef
        .child(_currentUser!.uid)
        .child(postId)
        .child('comments')
        .push();

    await commentRef.set({
      'userId': _currentUser!.uid,
      'message': commentText,
      'timestamp': DateTime.now().toIso8601String(),
    });

    Navigator.pop(context);
  }
}
