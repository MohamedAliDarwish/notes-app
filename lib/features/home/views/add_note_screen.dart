import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/core/app_colors.dart';
import 'package:notes_app/features/home/models/note_model.dart';
import 'package:notes_app/core/widgets/custom_icon_botton.dart';
import 'package:notes_app/features/home/cubit/note_cubit.dart';

class AddNoteScreen extends StatefulWidget {
  final NoteModel? note;

  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _selectedColor = widget.note != null
        ? Color(widget.note!.color)
        : AppColors.noteColors.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a note title"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (widget.note != null) {
      final updatedNote = NoteModel(
        id: widget.note!.id,
        title: title,
        content: content,
        color: _selectedColor.toARGB32(),
      );
      // cubit.updateNote(updatedNote);
      context.read<NoteCubit>().editNote(updatedNote);
    } else {
      final newNote = NoteModel(
        title: title,
        content: content,
        color: _selectedColor.toARGB32(),
      );
      context.read<NoteCubit>().addNewNote(newNote);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: Row(
          children: [
            CustomIconBotton(
              onPressed: () => Navigator.pop(context),
              icon: Icons.chevron_left,
            ),
          ],
        ),
        actions: [
          CustomIconBotton(onPressed: _saveNote, icon: Icons.check),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Title Field
              TextField(
                controller: _titleController,
                autofocus: !isEditing,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: "Title",
                  hintStyle: GoogleFonts.nunito(
                    color: Colors.white38,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 12),

              // Content Field
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.4,
                  ),
                  cursorColor: Colors.white,
                  decoration: InputDecoration(
                    hintText: "Type something...",
                    hintStyle: GoogleFonts.nunito(
                      color: Colors.white38,
                      fontSize: 20,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),

              // Color Selector Bar
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Text(
                      "Color:",
                      style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: AppColors.noteColors.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final color = AppColors.noteColors[index];
                            final isSelected =
                                _selectedColor.toARGB32() == color.toARGB32();
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.transparent,
                                    width: 3,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        size: 20,
                                        color: Color(0xFF252525),
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
