// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:notes_app/core/app_colors.dart';
// import 'package:notes_app/core/models/note_model.dart';
// import 'package:notes_app/features/home/cubit/note_cubit.dart';

// class NoteBottomSheet extends StatefulWidget {
//   final NoteModel? note;

//   const NoteBottomSheet({super.key, this.note});

//   @override
//   State<NoteBottomSheet> createState() => _NoteBottomSheetState();
// }

// class _NoteBottomSheetState extends State<NoteBottomSheet> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   late final TextEditingController _titleController;
//   late final TextEditingController _contentController;
//   late Color _selectedColor;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.note?.title ?? '');
//     _contentController = TextEditingController(text: widget.note?.content ?? '');
//     _selectedColor = widget.note != null
//         ? Color(widget.note!.color)
//         : AppColors.noteColors.first;
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _contentController.dispose();
//     super.dispose();
//   }

//   void _onSave() {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     final title = _titleController.text.trim();
//     final content = _contentController.text.trim();
//     final cubit = context.read<NoteCubit>();

//     if (widget.note != null) {
//       final updatedNote = NoteModel(
//         id: widget.note!.id,
//         title: title,
//         content: content,
//         color: _selectedColor.toARGB32(),
//       );
//       cubit.updateNote(updatedNote);
//     } else {
//       final newNote = NoteModel(
//         title: title,
//         content: content,
//         color: _selectedColor.toARGB32(),
//       );
//       cubit.addNewNote(newNote);
//     }

//     Navigator.pop(context);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.note != null;
//     final bottomInset = MediaQuery.of(context).viewInsets.bottom;

//     return Container(
//       decoration: const BoxDecoration(
//         color: AppColors.secondary,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: EdgeInsets.only(
//         left: 20,
//         right: 20,
//         top: 24,
//         bottom: bottomInset + 20,
//       ),
//       child: SingleChildScrollView(
//         child: Form(
//           key: _formKey,
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // Header
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     isEditing ? "Edit Note" : "Add Note",
//                     style: GoogleFonts.nunito(
//                       color: Colors.white,
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   IconButton(
//                     onPressed: () => Navigator.pop(context),
//                     icon: const Icon(Icons.close, color: Colors.white70),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               // Title Field
//               TextFormField(
//                 controller: _titleController,
//                 autofocus: !isEditing,
//                 style: GoogleFonts.nunito(color: Colors.white, fontSize: 18),
//                 decoration: InputDecoration(
//                   hintText: "Title",
//                   hintStyle: GoogleFonts.nunito(color: Colors.white54, fontSize: 18),
//                   filled: true,
//                   fillColor: AppColors.primary,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return "Please enter a title";
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 14),

//               // Content Field
//               TextFormField(
//                 controller: _contentController,
//                 maxLines: 5,
//                 style: GoogleFonts.nunito(color: Colors.white, fontSize: 16),
//                 decoration: InputDecoration(
//                   hintText: "Content",
//                   hintStyle: GoogleFonts.nunito(color: Colors.white54, fontSize: 16),
//                   filled: true,
//                   fillColor: AppColors.primary,
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                     borderSide: BorderSide.none,
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                 ),
//               ),
//               const SizedBox(height: 18),

//               // Color Selection Row
//               Text(
//                 "Color",
//                 style: GoogleFonts.nunito(
//                   color: Colors.white70,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               SizedBox(
//                 height: 42,
//                 child: ListView.separated(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: AppColors.noteColors.length,
//                   separatorBuilder: (_, __) => const SizedBox(width: 12),
//                   itemBuilder: (context, index) {
//                     final color = AppColors.noteColors[index];
//                     final isSelected = _selectedColor.toARGB32() == color.toARGB32();
//                     return GestureDetector(
//                       onTap: () {
//                         setState(() {
//                           _selectedColor = color;
//                         });
//                       },
//                       child: Container(
//                         width: 40,
//                         height: 40,
//                         decoration: BoxDecoration(
//                           color: color,
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: isSelected ? Colors.white : Colors.transparent,
//                             width: 3,
//                           ),
//                         ),
//                         child: isSelected
//                             ? const Icon(
//                                 Icons.check,
//                                 color: Color(0xFF252525),
//                                 size: 22,
//                               )
//                             : null,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Save Button
//               ElevatedButton(
//                 onPressed: _onSave,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.white,
//                   foregroundColor: const Color(0xFF252525),
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: Text(
//                   isEditing ? "Save Changes" : "Add Note",
//                   style: GoogleFonts.nunito(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
