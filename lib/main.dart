import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/features/home/cubit/home_cubit.dart';
import 'package:notes_app/features/home/views/home_screen.dart';

void main() {
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
          textTheme: const TextTheme(),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
