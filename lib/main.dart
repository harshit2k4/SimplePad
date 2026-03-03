import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simplepad/models/note_model.dart';
import 'package:simplepad/views/home_page.dart';

void main() async {
  // This makes sure Flutter is ready before we start Hive
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for Flutter
  await Hive.initFlutter();

  // Register the NoteModel adapter
  Hive.registerAdapter(NoteModelAdapter());

  // Open the box (database) so it is ready for use
  await Hive.openBox<NoteModel>('notes_box');

  runApp(const SimplePadApp());
}

class SimplePadApp extends StatelessWidget {
  const SimplePadApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SimplePad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: HomePage(),
    );
  }
}
