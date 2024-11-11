import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_pad/screens/home.dart';

void main() async {
  //var directory = await getApplicationDocumentsDirectory();
  //Hive.init(directory.path);
  //Hive.registerAdapter(NoteAdapter());
  //await Hive.openBox<Note>(kNoteBox);

  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('open_note');
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
