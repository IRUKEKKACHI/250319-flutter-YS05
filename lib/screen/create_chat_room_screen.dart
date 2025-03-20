import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateChatRoomScreen extends StatefulWidget {
  @override
  State<CreateChatRoomScreen> createState() => _CreateChatRoomScreenState();
}

class _CreateChatRoomScreenState extends State<CreateChatRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isPrivate = false;
  bool _isLoading = false;

  @override
  void dispose() {
    titleController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _createChatRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) return;
        DocumentReference chatRoom =
            await FirebaseFirestore.instance.collection('chatrooms').add({
          'title': titleController.text.trim(),
          'isPrivate': isPrivate,
          'password': isPrivate ? passwordController.text : null,
          'ownerId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("New Chat Room Created"),
                content: Text("Chat room is created successfully."),
                actions: [
                  TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/chat', arguments: {
                            'chatRoomId': chatRoom.id,
                            'chatRoomTitle': titleController.text.trim(),
                            'ownerId': user.uid,
                          }),
                      child: Text('OK'))
                ],
              );
            });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error occurred'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Chat Room'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Chat Room Title'),
                  validator: (value) => value!.isEmpty ? 'Enter a title' : null,
                ),
              ),
              SwitchListTile(
                title: Text('Private Chat Room'),
                value: isPrivate,
                onChanged: (value) {
                  setState(() {
                    isPrivate = value;
                  });
                },
              ),
              if (isPrivate)
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    validator: (value) =>
                        value!.isEmpty ? 'Enter a password' : null,
                  ),
                ),
              SizedBox(height: 20),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _createChatRoom,
                      child: Text('Create'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}
