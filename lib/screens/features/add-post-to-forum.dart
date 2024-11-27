import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
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
    if (_captionController.text.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a caption or select images'),
          backgroundColor: Colors.red,
        ),
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
      if (_selectedImages.isNotEmpty) {
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
      }

      Map<String, dynamic> forumData = {
        'userId': userId,
        'caption': _captionController.text,
        'images': imageUrls,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await forumRef.set(forumData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post added successfully'),
          backgroundColor: Colors.green,
        ),
      );

      _captionController.clear();
      setState(() {
        _selectedImages.clear();
      });
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
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        title: Text('Add Post To Forum', style: GoogleFonts.robotoCondensed()),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Caption Input
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                labelText: 'Caption (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Image Picker
            ElevatedButton.icon(
              onPressed: _pickImages,
              icon: const Icon(Icons.photo),
              label: Text(
                'Pick Images',
                style: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Selected Images Preview
            _selectedImages.isNotEmpty
                ? Wrap(
                    spacing: 10,
                    children: _selectedImages.map((img) {
                      return Stack(
                        children: [
                          Image.file(img,
                              width: 100, height: 100, fit: BoxFit.cover),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _selectedImages.remove(img);
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  )
                : const Text('No images selected'),

            const Spacer(),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _addPost,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      'Submit Post',
                      style: GoogleFonts.robotoCondensed(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                textStyle: GoogleFonts.robotoCondensed(
                  fontSize: 16,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
