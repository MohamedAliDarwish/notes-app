import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/features/home/models/note_model.dart';

class HiveDataSource {
  final Box _box = Hive.box("notes");

  Future<void> addNote(NoteModel note) async {
    await _box.put(note.id, note);
  }

  List<NoteModel> getNote() {
    return _box.values.cast<NoteModel>().toList();
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  Future<void> editNote(NoteModel note) async {
    await _box.put(note.id, note);
  }
}

// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:notes_app/core/models/note_model.dart';

// class HiveDataSource {
//   final Box _box = Hive.box("notes");

//   Future<int> addNote(NoteModel note) async {
//     int key = await _box.add(note);
//     return key;
//   }

//   List<NoteModel> getNote() {
//     final List<NoteModel> notes = _box.values.cast<NoteModel>().toList();
//     return notes;
//   }

//   Future<void> deleteNote(int key) async {
//     await _box.delete(key);
//   }
// }
