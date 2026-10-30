import 'package:notes_app/features/home/models/note_model.dart';

sealed class NoteState {}

class NotesInitState extends NoteState {}

class NotesLoadingState extends NoteState {}

class NotesSuccessState extends NoteState {}

class NotesSuccessDataState extends NoteState {
  List<NoteModel> notes;
  NotesSuccessDataState({required this.notes});
}

class NotesFailState extends NoteState {
  final String errorMessage;

  NotesFailState({required this.errorMessage});
}
