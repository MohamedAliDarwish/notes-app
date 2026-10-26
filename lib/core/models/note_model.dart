class NoteModel {
  final int? id;
  final String title;
  final String? content;
  final int color;

  NoteModel({
    this.id,
    required this.title,
    this.content,
    required this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'content': content ?? '',
      'color': color,
    };
  }
}