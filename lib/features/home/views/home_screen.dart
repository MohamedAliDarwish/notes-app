import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/core/app_colors.dart';
import 'package:notes_app/features/home/models/note_model.dart';
import 'package:notes_app/core/widgets/custom_icon_botton.dart';
import 'package:notes_app/features/home/cubit/note_cubit.dart';
import 'package:notes_app/features/home/cubit/note_state.dart';
import 'package:notes_app/features/home/views/add_note_screen.dart';
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!mounted) return;
    //   context.read<NoteCubit>().getAllNotes();
    // });
    context.read<NoteCubit>().getAllNotes();
  }

  void _openAddNoteScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddNoteScreen()),
    );
  }

  void _openEditNoteScreen(NoteModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddNoteScreen(note: note)),
    );
  }

  void _deleteNote(NoteModel note) {
    context.read<NoteCubit>().deleteNote(note.id);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }

  Widget _buildError(String message) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: GoogleFonts.nunito(color: Colors.redAccent, fontSize: 18),
      ),
    );
  }

  Widget _buildEmptyNotes() {
    return Center(
      child: Text(
        'No notes found',
        style: GoogleFonts.nunito(
          color: Colors.white60,
          fontSize: 20,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildNotesList(List<NoteModel> notes) {
    return ListView.builder(
      itemCount: notes.length,

      findChildIndexCallback: (Key key) {
        if (key is ValueKey<String>) {
          final index = notes.indexWhere((note) => note.id == key.value);

          return index == -1 ? null : index;
        }

        return null;
      },

      itemBuilder: (context, index) {
        final note = notes[index];

        return Dismissible(
          key: ValueKey<String>(note.id),

          direction: DismissDirection.endToStart,

          background: Container(
            margin: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 24),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.delete, color: Colors.white, size: 32),
          ),

          onDismissed: (direction) {
            _deleteNote(note);
            _showMessage("Note '${note.title}' deleted");
          },

          child: NoteItem(
            noteModel: note,
            onTap: () {
              _openEditNoteScreen(note);
            },
          ),
        );
      },
    );
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
          'Notes',
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w600,
          ),
        ),

        actions: [
          CustomIconBotton(
            onPressed: () {
              // Search will be implemented later.
            },
            icon: Icons.search,
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        child: BlocConsumer<NoteCubit, NoteState>(
          listener: (context, state) {
            if (state is NotesFailState) {
              _showMessage(state.errorMessage);
            }
          },

          builder: (context, state) {
            if (state is NotesLoadingState) {
              return _buildLoading();
            }

            if (state is NotesFailState) {
              return _buildError(state.errorMessage);
            }

            if (state is NotesSuccessDataState) {
              if (state.notes.isEmpty) {
                return _buildEmptyNotes();
              }

              return _buildNotesList(state.notes);
            }

            return const SizedBox.shrink();
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNoteScreen,
        backgroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.add, color: Color(0xFF252525), size: 32),
      ),
    );
  }
}
