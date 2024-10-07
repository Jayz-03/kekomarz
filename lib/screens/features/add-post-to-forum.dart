import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // Add this

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

  // Pick multiple images
  Future<void> _pickImages() async {
    final List<XFile>? pickedImages = await _imagePicker.pickMultiImage();
    if (pickedImages != null) {
      setState(() {
        _selectedImages.addAll(pickedImages.map((img) => File(img.path)));
      });
    }
  }

  // Compress image before uploading
  Future<XFile?> _compressImage(File file) async {
    final compressedFile = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      '${file.path}_compressed.jpg',
      quality: 50, // Adjust quality to compress
    );
    return compressedFile;
  }

  // Function to upload the forum post
  Future<void> _addPost() async {
    if (_captionController.text.isEmpty || _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a caption and select images')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get current logged-in user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user logged in");
      }

      String userId = user.uid;

      // Generate a new forumId
      DatabaseReference forumRef =
          FirebaseDatabase.instance.ref().child('Forum').child(userId).push();
      String forumId = forumRef.key!;

      // Upload images to Firebase Storage
      List<String> imageUrls = [];
      await Future.wait(_selectedImages.map((image) async {
        XFile? compressedImage = await _compressImage(image); // Compress image first
        if (compressedImage == null) return;

        String imageName = const Uuid().v4(); // Generate unique filename
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('forum_images/$forumId/$imageName.jpg');
        UploadTask uploadTask = storageRef.putFile(compressedImage as File); // Upload compressed image

        TaskSnapshot snapshot = await uploadTask.whenComplete(() {});
        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl); // Add the image URL to the list
      }).toList());

      // Prepare the post data with image URLs
      Map<String, dynamic> forumData = {
        'userId': userId,
        'caption': _captionController.text,
        'images': imageUrls, // Store the image URLs
      };

      // Save post info to Firebase Realtime Database
      await forumRef.set(forumData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post added successfully')),
      );

      // Clear the fields after posting
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
