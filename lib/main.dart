import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/core/data_source/hive_data_source.dart';
import 'package:notes_app/features/home/models/note_model.dart';
import 'package:notes_app/features/home/cubit/note_cubit.dart';
import 'package:notes_app/features/home/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(NoteModelAdapter());
  await Hive.openBox("notes");
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NoteCubit>(
      create: (context) => NoteCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Notes App",
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xff252525),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
