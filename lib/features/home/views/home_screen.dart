import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/core/app_colors.dart';
import 'package:notes_app/core/widgets/custom_icon_botton.dart';
import 'package:notes_app/features/editor/views/editor_screen.dart';
import 'package:notes_app/features/home/cubit/home_cubit.dart';
import 'package:notes_app/features/home/cubit/home_state.dart';
import 'package:notes_app/features/home/widgets/note_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NoteCubit>().getAllNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        actionsPadding: const EdgeInsets.only(right: 20),
        title: Text(
          "Notes",
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          CustomIconBotton(onPressed: () {}, icon: Icons.search),
          const SizedBox(width: 12),
          CustomIconBotton(onPressed: () {}, icon: Icons.info_outline),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: BlocBuilder<NoteCubit, NoteState>(
          builder: (context, state) {
            if (state is NotesInitState) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (state.notes.isEmpty) {
              return Center(
                child: Text(
                  "No notes found",
                  style: GoogleFonts.nunito(
                    color: Colors.white60,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              );
            }
            return ListView.builder(
              itemCount: state.notes.length,
              itemBuilder: (context, index) {
                final note = state.notes[index];
                return Dismissible(
                  key: ValueKey(note.id ?? index),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  onDismissed: (direction) {
                    if (note.id != null) {
                      context.read<NoteCubit>().deleteNote(id: note.id!);
                    }
                  },
                  child: NoteItem(
                    noteModel: note,
                    onTap: () {
                      final cubit = context.read<NoteCubit>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: cubit,
                            child: EditorScreen(noteModel: note),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final cubit = context.read<NoteCubit>();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: const EditorScreen(),
              ),
            ),
          );
        },
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(
          Icons.add,
          color: Color(0xFF252525),
          size: 32,
        ),
      ),
    );
  }
}
