import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:notes_app/core/data_source/hive_data_source.dart';
import 'package:notes_app/features/home/models/note_model.dart';
import 'package:notes_app/features/home/cubit/note_state.dart';

class NoteCubit extends Cubit<NoteState> {
  NoteCubit() : super(NotesInitState());

  final HiveDataSource _hiveDataSource = HiveDataSource();

  List<NoteModel> allNotes = [];

  void _refreshNotes() {
    allNotes = _hiveDataSource.getNote();

    emit(NotesSuccessDataState(notes: List<NoteModel>.from(allNotes)));
  }

  void getAllNotes() {
    emit(NotesLoadingState());

    try {
      _refreshNotes();
    } catch (error) {
      emit(NotesFailState(errorMessage: error.toString()));
    }
  }

  Future<void> addNewNote(NoteModel note) async {
    try {
      await _hiveDataSource.addNote(note);
      _refreshNotes();
    } catch (error) {
      emit(NotesFailState(errorMessage: error.toString()));
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _hiveDataSource.deleteNote(id);
      _refreshNotes();
    } catch (error) {
      emit(NotesFailState(errorMessage: error.toString()));
    }
  }

  Future<void> editNote(NoteModel note) async {
    try {
      await _hiveDataSource.editNote(note);
      _refreshNotes();
    } catch (error) {
      emit(NotesFailState(errorMessage: error.toString()));
    }
  }
}
