import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kekomarz/screens/inbox/conversation.dart';

class InboxScreen extends StatelessWidget {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final String adminId = 'i76ANAK58hTb2U0HZg17sPxrILR2';

  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox', style: GoogleFonts.robotoCondensed()),
      ),
      body: StreamBuilder(
        stream: _usersRef.child(adminId).onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final userData = Map<String, dynamic>.from(snapshot.data!.snapshot.value as Map);

            return ListView(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text('${userData['firstName']} ${userData['lastName']}', style: GoogleFonts.robotoCondensed()),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConversationScreen(
                          adminId: adminId,
                          userId: currentUserId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          } else {
            return const Center(child: Text('Admin not found.'));
          }
        },
      ),
    );
  }
}
