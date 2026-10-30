import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:notes_app/core/data_source/hive_data_source.dart';
import 'package:notes_app/features/home/models/note_model.dart';

void main() {
  late Directory tempDirectory;
  late HiveDataSource dataSource;

  setUp(() async {
    tempDirectory = await Directory.systemTemp.createTemp('notes_app_test');
    Hive.init(tempDirectory.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteModelAdapter());
    }
    await Hive.openBox('notes');
    dataSource = HiveDataSource();
  });

  tearDown(() async {
    await Hive.close();
    await tempDirectory.delete(recursive: true);
  });

  test('deletes a note using its persisted id', () async {
    final note = NoteModel(id: 'note-id', title: 'Test note', color: 0);

    await dataSource.addNote(note);

    final loadedNote = dataSource.getNote().single;
    expect(loadedNote.id, note.id);

    await dataSource.deleteNote(loadedNote.id);

    expect(dataSource.getNote(), isEmpty);
  });

  test('keeps notes after reopening the Hive box', () async {
    final note = NoteModel(id: 'note-id', title: 'Saved note', color: 0);

    await dataSource.addNote(note);
    await Hive.close();
    await Hive.openBox('notes');

    expect(HiveDataSource().getNote().single.title, note.title);
  });
}
