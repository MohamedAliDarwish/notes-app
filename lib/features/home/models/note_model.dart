import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String? content;

  @HiveField(3)
  final int color;

  NoteModel({
    String? id,
    required this.title,
    this.content,
    required this.color,
  }) : id = id ?? const Uuid().v4();
}

//  flutter pub add dev:hive_generator dev:build_runner

// flutter run build_runner build

// flutter run build_runner build --delete-conflicting-outputs
