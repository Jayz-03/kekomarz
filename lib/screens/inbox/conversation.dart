import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

import 'package:google_fonts/google_fonts.dart';

class ConversationScreen extends StatefulWidget {
  final String adminId;
  final String userId;

  const ConversationScreen({
    super.key,
    required this.adminId,
    required this.userId,
  });

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final DatabaseReference _messagesRef = FirebaseDatabase.instance.ref('messages');
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _chatMessages = [];
  late StreamSubscription<DatabaseEvent> _messageSubscription;

  @override
  void initState() {
    super.initState();
    _fetchConversation();
  }

  void _fetchConversation() {
    _messageSubscription = _messagesRef.child(widget.userId).onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        List<Map<String, dynamic>> messages = [];
        data.forEach((key, value) {
          messages.add({
            'messageId': key,
            ...Map<String, dynamic>.from(value),
          });
        });

        // Sort messages by timestamp to display in order
        messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));

        // Ensure setState is only called when the widget is mounted
        if (mounted) {
          setState(() {
            _chatMessages = messages;
          });

          // Scroll to the bottom when new messages arrive
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
            }
          });
        }
      }
    });
  }

  void _sendMessage(String messageContent) {
    if (messageContent.trim().isEmpty) return;

    // Get the current user's ID from Firebase Auth
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    final newMessage = {
      'senderId': currentUserId, // Use the current user's ID
      'message': messageContent,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    _messagesRef.child(currentUserId).push().set(newMessage);

    _messageController.clear();
  }

  @override
  void dispose() {
    _messageSubscription.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 200, 164, 212),
        title: Text('Chat with Kekomarz', style: GoogleFonts.robotoCondensed()),
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
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final chat = _chatMessages[index];
                final isUserMessage = chat['senderId'] == FirebaseAuth.instance.currentUser!.uid;

                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat['message'],
                          style: GoogleFonts.robotoCondensed(
                            color: isUserMessage ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          isUserMessage ? 'You' : 'Admin',
                          style: GoogleFonts.robotoCondensed(
                            fontSize: 12,
                            color: isUserMessage ? Colors.white70 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _sendMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
