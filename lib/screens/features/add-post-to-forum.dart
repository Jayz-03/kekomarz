import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class AddPostToForumScreen extends StatefulWidget {
  const AddPostToForumScreen({super.key});

  @override
  _AddPostToForumScreenState createState() => _AddPostToForumScreenState();
}

class _AddPostToForumScreenState extends State<AddPostToForumScreen> {
  final TextEditingController _captionController = TextEditingController();
  final List<File> _selectedImages = [];
  final _imagePicker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _selectedImages.addAll(pickedImages.map((img) => File(img.path)));
      });
    }
  }

  Future<void> _addPost() async {
    if (_captionController.text.isEmpty || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please add a caption and select images'),
            backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      String userId = user.uid;

      DatabaseReference forumRef =
          FirebaseDatabase.instance.ref().child('Forum').child(userId).push();
      String forumId = forumRef.key!;

      List<String> imageUrls = [];
      for (File image in _selectedImages) {
        String imageName = const Uuid().v4();
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('forum_images/$forumId/$imageName.jpg');

        UploadTask uploadTask = storageRef.putFile(image);
        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      Map<String, dynamic> forumData = {
        'userId': userId,
        'caption': _captionController.text,
        'images': imageUrls,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await forumRef.set(forumData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post added successfully'), ),
      );

      _captionController.clear();
      _selectedImages.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post to Forum'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo),
              label: const Text('Pick Images'),
            ),
            const SizedBox(height: 16),
            _selectedImages.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    children: _selectedImages.map((img) {
                      return Image.file(img,
                          width: 100, height: 100, fit: BoxFit.cover);
                    }).toList(),
                  )
                : const Text('No images selected'),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _addPost,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Post'),
            ),
          ],
        ),
      ),
    );
  }
}
