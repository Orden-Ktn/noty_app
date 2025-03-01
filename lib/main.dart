import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'screens/splash.dart';
import 'models/user.dart';
import 'models/note.dart';

late Isar isar;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  isar = await Isar.open(
    [UserSchema, NoteSchema],
    directory: dir.path,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bloc-notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}