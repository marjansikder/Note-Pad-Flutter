import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:note_pad/screens/home.dart';
import 'package:path_provider/path_provider.dart';
import 'constant/colors.dart';
import 'models/notes_model.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  //var directory = await getApplicationDocumentsDirectory();
  //Hive.init(directory.path);

  //Hive.registerAdapter(NoteAdapter());
  //await Hive.openBox<Note>(kNoteBox);
  await Hive.initFlutter();
  await Hive.openBox('open_note');
  runApp( MainApp());
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