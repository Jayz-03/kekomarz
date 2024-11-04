import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:io';

import 'package:kekomarz/screens/auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  String? _profileImageUrl;
  String? _userId;
  String _firstName = '';
  String _lastName = '';
  String _address = '';
  String _email = '';
  String _mobileNumber = '';

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _userId = user.uid;
      DatabaseReference userRef = _database.ref('users/$_userId');
      DatabaseEvent event = await userRef.once();
      final userData = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        _firstName = userData['firstName'] ?? '';
        _lastName = userData['lastName'] ?? '';
        _address = userData['address'] ?? '';
        _email = userData['email'] ?? '';
        _mobileNumber = userData['mobileNumber'] ?? '';
        _profileImageUrl = userData['profileImageUrl'];
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_userId != null) {
      DatabaseReference userRef = _database.ref('users/$_userId');
      await userRef.update({
        'firstName': _firstName,
        'lastName': _lastName,
        'address': _address,
        'mobileNumber': _mobileNumber,
        'profileImageUrl': _profileImageUrl,
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String fileName = pickedFile.path.split('/').last;
      Reference storageRef = _storage.ref().child('profile_images/$fileName');
      await storageRef.putFile(File(pickedFile.path));
      String downloadUrl = await storageRef.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadUrl;
      });
      await _updateProfile();
    } else {
      print('No image selected.');
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.robotoCondensed(),),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : null,
                child: _profileImageUrl == null
                    ? const Icon(Icons.camera_alt, size: 50)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              cursorColor: Colors.black,
              onChanged: (value) => _firstName = value,
              controller: TextEditingController(text: _firstName),
              style: GoogleFonts.robotoCondensed(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'First Name',
                hintStyle: GoogleFonts.robotoCondensed(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              cursorColor: Colors.black,
              onChanged: (value) => _lastName = value,
              controller: TextEditingController(text: _lastName),
              style: GoogleFonts.robotoCondensed(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: 'Last Name',
                hintStyle: GoogleFonts.robotoCondensed(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              cursorColor: Colors.black,
              onChanged: (value) => _address = value,
              controller: TextEditingController(text: _address),
              style: GoogleFonts.robotoCondensed(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on),
                hintText: 'Address',
                hintStyle: GoogleFonts.robotoCondensed(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              cursorColor: Colors.black,
              readOnly: true,
              controller: TextEditingController(text: _email),
              style: GoogleFonts.robotoCondensed(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                hintText: 'Email',
                hintStyle: GoogleFonts.robotoCondensed(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              cursorColor: Colors.black,
              onChanged: (value) => _mobileNumber = value,
              controller: TextEditingController(text: _mobileNumber),
              style: GoogleFonts.robotoCondensed(),
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.phone),
                hintText: 'Mobile Number',
                hintStyle: GoogleFonts.robotoCondensed(),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: Colors.black,
                    width: 2.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signOut,
              child: Text(
                'Sign Out',
                style: GoogleFonts.robotoCondensed(
                    fontSize: 16, color: Colors.red),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                textStyle: GoogleFonts.robotoCondensed(
                    fontSize: 16, color: Colors.white),
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
