import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/database/database_helper.dart';
import 'package:notes_app/core/models/note_model.dart';
import 'package:notes_app/features/home/cubit/home_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(NotesInitState(notes: []));

  // get all Notes:
  void getAllNotes() async {
    List<NoteModel> notes = [];
    List<Map<String, dynamic>> allNotesList = await DatabaseHelper.getAllNotes();
    for (var note in allNotesList) {
      notes.add(NoteModel(
        id: note["id"] as int?,
        title: note["title"] as String,
        content: note["content"] as String?,
        color: note["color"] as int,
      ));
    }
    emit(AllNotesState(notes: notes));
  }

  void addNewNote(NoteModel note) async {
    await DatabaseHelper.addNote(note.toMap());
    getAllNotes();
  }

  void updateNote(NoteModel note) async {
    if (note.id != null) {
      await DatabaseHelper.updateNote(note.toMap(), note.id!);
      getAllNotes();
    }
  }

  void deleteNote({required int id}) async {
    // 1. Optimistically remove from state so the UI and Dismissible update immediately
    final updatedNotes = state.notes.where((note) => note.id != id).toList();
    emit(DeleteNoteState(notes: updatedNotes));

    // 2. Delete from database
    await DatabaseHelper.deleteNote(id: id);
  }
}