import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatRoomId;
  final String chatRoomTitle;
  final String ownerId;

  const ChatRoomScreen({
    required this.chatRoomId,
    required this.chatRoomTitle,
    required this.ownerId,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final TextEditingController messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('chatrooms')
          .doc(widget.chatRoomId)
          .collection('messages')
          .add({
        'text': text,
        'senderId': user.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
      messageController.clear();
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to send message'),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> _deleteCharRoom() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.uid == widget.ownerId) {
      try {
        await FirebaseFirestore.instance
            .collection('chatrooms')
            .doc(widget.chatRoomId)
            .delete();
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Deleted Successfully"),
                content: Text("The chat room is deleted successfully."),
                actions: [
                  TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/'),
                      child: Text('OK'))
                ],
              );
            });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Occurred unknown error during deleting the chat room.'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messageStream = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        title: Text(widget.chatRoomTitle),
        actions: [
          if (FirebaseAuth.instance.currentUser?.uid == widget.ownerId)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: _deleteCharRoom,
            )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messageStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(
                        data['senderId'].toString().substring(0, 10) ?? '',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        data['text'] ?? '',
                        style: TextStyle(fontSize: 20),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
