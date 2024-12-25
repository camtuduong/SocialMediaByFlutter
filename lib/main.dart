import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socialmediaapp/app.dart';
import 'package:socialmediaapp/config/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load file .env
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}
