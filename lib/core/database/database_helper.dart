import 'package:notes_app/core/database/notes_database.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Future<List<Map<String, dynamic>>> getAllNotes() async {
    Database noteDB = await NoteDatabase.noteDatabase.database;
    return await noteDB.query("notes", orderBy: "id DESC");
  }

  static Future<int> addNote(Map<String, dynamic> note) async {
    Database noteDB = await NoteDatabase.noteDatabase.database;
    return await noteDB.insert("notes", note);
  }

  static Future<int> updateNote(Map<String, dynamic> note, int id) async {
    Database noteDB = await NoteDatabase.noteDatabase.database;
    return await noteDB.update("notes", note, where: "id = ?", whereArgs: [id]);
  }

  static Future<int> deleteNote({required int id}) async {
    Database noteDB = await NoteDatabase.noteDatabase.database;
    return await noteDB.delete("notes", where: "id = ?", whereArgs: [id]);
  }
}