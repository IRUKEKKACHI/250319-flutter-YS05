import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_ys05_20250319/firebase_options.dart';
import 'package:flutter_ys05_20250319/screen/chat_room_list_screen.dart';
import 'package:flutter_ys05_20250319/screen/chat_room_screen.dart';
import 'package:flutter_ys05_20250319/screen/create_chat_room_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.signInAnonymously();
    } catch (e) {
      print('Failed Anonymous Login : $e');
    }
  }

  runApp(FlutterYS05());
}

class FlutterYS05 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => ChatRoomListScreen(),
        '/create': (context) => CreateChatRoomScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return null;
        }
        return null;
      },
    );
  }
}
