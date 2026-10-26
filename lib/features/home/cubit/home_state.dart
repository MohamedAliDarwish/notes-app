import 'package:notes_app/core/models/note_model.dart';

sealed class NoteState {
  final List<NoteModel> notes;

  NoteState({required this.notes});
}


class NotesInitState extends NoteState{
  NotesInitState({required super.notes});
}

class AllNotesState extends NoteState{
  AllNotesState({required super.notes});
}

class AddNotsState extends NoteState{
  AddNotsState({required super.notes});
}

class DeleteNoteState extends NoteState{
  DeleteNoteState({required super.notes});
}