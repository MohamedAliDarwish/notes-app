import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/core/models/note_model.dart';

class NoteItem extends StatelessWidget {
  final NoteModel noteModel;
  final VoidCallback? onTap;

  const NoteItem({
    super.key,
    required this.noteModel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(noteModel.color),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          noteModel.title,
          style: GoogleFonts.nunito(
            color: const Color(0xFF252525),
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.3,
          ),
        ),
      ),
    );
  }
}
