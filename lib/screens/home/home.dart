import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:kekomarz/screens/features/about-us.dart';
import 'package:kekomarz/screens/features/forum.dart';
import 'package:kekomarz/screens/features/order.dart';
import 'package:kekomarz/screens/features/parts.dart';
import 'package:kekomarz/screens/features/service-progress.dart';
import 'package:kekomarz/screens/features/service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String firstName = '';
  String lastName = '';
  String email = '';
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final userId = user.uid;
      DatabaseReference userRef =
          FirebaseDatabase.instance.ref().child('users/$userId');

      final snapshot = await userRef.get();
      if (snapshot.exists) {
        setState(() {
          firstName = snapshot.child('firstName').value as String? ?? '';
          lastName = snapshot.child('lastName').value as String? ?? '';
          email = snapshot.child('email').value as String? ?? '';
          profileImageUrl =
              snapshot.child('profileImageUrl').value as String? ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : AssetImage('assets/images/default_image.png')
                            as ImageProvider,
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$firstName $lastName",
                        style: GoogleFonts.robotoCondensed(
                            color: Color.fromARGB(255, 59, 27, 13),
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        email,
                        style: GoogleFonts.robotoCondensed(
                            color: Color.fromARGB(255, 59, 27, 13),
                            fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 40, right: 40),
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 100, 59, 159),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    SizedBox(width: 10),
                    Icon(Icons.search, color: Colors.white),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        style: GoogleFonts.robotoCondensed(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search',
                          hintStyle:
                              GoogleFonts.robotoCondensed(color: Colors.white),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 260,
              child: GridView.count(
                crossAxisCount: 3,
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(4.0),
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                children: <Widget>[
                  _buildTile(context, Icons.motorcycle, 'Parts', PartsScreen()),
                  _buildTile(context, Icons.build, 'Service', ServiceScreen()),
                  _buildTile(context, Icons.update, 'Service Progress',
                      ServiceProgressScreen()),
                  _buildTile(context, Icons.forum, 'Forum', ForumScreen()),
                  _buildTile(
                      context, Icons.shopping_cart, 'Orders', OrderScreen()),
                  _buildTile(context, Icons.info, 'About us', AboutUsScreen()),
                ],
              ),
            ),
            Divider(color: Color.fromARGB(255, 100, 59, 159)),
            const SizedBox(height: 10),
            Text(
              'Top Post',
              style: GoogleFonts.robotoCondensed(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(
      BuildContext context, IconData icon, String title, Widget destination) {
    return Card(
      color: Color.fromARGB(255, 149, 121, 171),
      child: InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => destination)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 60.0, color: Colors.white),
            Text(title,
                style: GoogleFonts.robotoCondensed(
                    color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
