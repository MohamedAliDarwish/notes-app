import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/core/app_colors.dart';
import 'package:notes_app/core/models/note_model.dart';
import 'package:notes_app/core/widgets/custom_icon_botton.dart';
import 'package:notes_app/features/home/cubit/home_cubit.dart';

/// Custom TextEditingController that highlights markdown styling in real-time
class MarkdownEditingController extends TextEditingController {
  MarkdownEditingController({super.text});

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final baseStyle = style ?? const TextStyle(color: Colors.white, fontSize: 18);
    final textContent = text;
    if (textContent.isEmpty) {
      return TextSpan(text: '', style: baseStyle);
    }

    final children = <InlineSpan>[];
    // Regex matching bold, underline, italic, code, and links
    final pattern = RegExp(
      r'(\*\*(.*?)\*\*)|'       // Group 1 & 2: **bold**
      r'(__([^_]+)__)|'         // Group 3 & 4: __underline__
      r'(\*([^*]+)\*)|'         // Group 5 & 6: *italic*
      r'(`([^`]+)`)|'           // Group 7 & 8: `code`
      r'(\[(.*?)\]\((.*?)\))',  // Group 9, 10, 11: [title](url)
      multiLine: true,
    );

    int lastMatchEnd = 0;
    for (final match in pattern.allMatches(textContent)) {
      if (match.start > lastMatchEnd) {
        children.add(TextSpan(
          text: textContent.substring(lastMatchEnd, match.start),
          style: baseStyle,
        ));
      }

      if (match.group(1) != null) {
        // Bold: **text**
        children.add(TextSpan(
          text: '**',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
        children.add(TextSpan(
          text: match.group(2) ?? '',
          style: baseStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ));
        children.add(TextSpan(
          text: '**',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
      } else if (match.group(3) != null) {
        // Underline: __text__
        children.add(TextSpan(
          text: '__',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
        children.add(TextSpan(
          text: match.group(4) ?? '',
          style: baseStyle.copyWith(
            decoration: TextDecoration.underline,
            decorationColor: Colors.white,
            color: Colors.white,
          ),
        ));
        children.add(TextSpan(
          text: '__',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
      } else if (match.group(5) != null) {
        // Italic: *text*
        children.add(TextSpan(
          text: '*',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
        children.add(TextSpan(
          text: match.group(6) ?? '',
          style: baseStyle.copyWith(
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ));
        children.add(TextSpan(
          text: '*',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
      } else if (match.group(7) != null) {
        // Code: `text`
        children.add(TextSpan(
          text: match.group(0),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: const Color(0x33FFFFFF),
            color: const Color(0xFFFFD54F),
          ),
        ));
      } else if (match.group(9) != null) {
        // Link: [title](url)
        children.add(TextSpan(
          text: '[${match.group(10)}]',
          style: baseStyle.copyWith(
            color: const Color(0xFF64B5F6),
            decoration: TextDecoration.underline,
          ),
        ));
        children.add(TextSpan(
          text: '(${match.group(11)})',
          style: baseStyle.copyWith(color: Colors.white38),
        ));
      }

      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < textContent.length) {
      children.add(TextSpan(
        text: textContent.substring(lastMatchEnd),
        style: baseStyle,
      ));
    }

    return TextSpan(children: children);
  }
}

class EditorScreen extends StatefulWidget {
  final NoteModel? noteModel;

  const EditorScreen({super.key, this.noteModel});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late final TextEditingController _titleController;
  late final MarkdownEditingController _contentController;
  late Color _selectedColor;
  bool _isPreviewMode = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.noteModel?.title ?? '');
    _contentController = MarkdownEditingController(text: widget.noteModel?.content ?? '');
    _selectedColor = widget.noteModel != null
        ? Color(widget.noteModel!.color)
        : AppColors.noteColors.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  /// Formats selected text with wrapping symbols (e.g. **bold**, *italic*, __underline__)
  void _formatWrap(String prefix, String suffix) {
    if (_isPreviewMode) return;

    final text = _contentController.text;
    final selection = _contentController.selection;

    if (!selection.isValid) {
      final newText = '$text$prefix$suffix';
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length - suffix.length),
      );
      return;
    }

    final start = selection.start;
    final end = selection.end;

    if (start == end) {
      // Insert markers with cursor between them
      final newText = text.replaceRange(start, end, '$prefix$suffix');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + prefix.length),
      );
    } else {
      final selectedText = text.substring(start, end);
      // Toggle unwrap if already wrapped
      if (selectedText.startsWith(prefix) &&
          selectedText.endsWith(suffix) &&
          selectedText.length >= prefix.length + suffix.length) {
        final unwrapped = selectedText.substring(
          prefix.length,
          selectedText.length - suffix.length,
        );
        final newText = text.replaceRange(start, end, unwrapped);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start,
            extentOffset: start + unwrapped.length,
          ),
        );
      } else {
        final wrapped = '$prefix$selectedText$suffix';
        final newText = text.replaceRange(start, end, wrapped);
        _contentController.value = TextEditingValue(
          text: newText,
          selection: TextSelection(
            baseOffset: start,
            extentOffset: start + wrapped.length,
          ),
        );
      }
    }
  }

  /// Prepends prefix at the start of current line (e.g. lists, quotes, headings)
  void _formatLinePrefix(String prefix) {
    if (_isPreviewMode) return;

    final text = _contentController.text;
    final selection = _contentController.selection;
    final cursor = selection.isValid ? selection.start : text.length;

    final lineStart = text.lastIndexOf('\n', cursor > 0 ? cursor - 1 : 0);
    final insertPos = lineStart == -1 ? 0 : lineStart + 1;

    final lineSub = text.substring(insertPos);
    if (lineSub.startsWith(prefix)) {
      final newText = text.replaceRange(insertPos, insertPos + prefix.length, '');
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
          offset: (cursor - prefix.length).clamp(0, newText.length),
        ),
      );
    } else {
      final newText = text.replaceRange(insertPos, insertPos, prefix);
      _contentController.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: cursor + prefix.length),
      );
    }
  }

  void _insertLink() {
    _formatWrap('[', '](https://)');
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

    if (widget.noteModel != null) {
      final updatedNote = NoteModel(
        id: widget.noteModel!.id,
        title: title,
        content: content,
        color: _selectedColor.toARGB32(),
      );
      context.read<NoteCubit>().updateNote(updatedNote);
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
          CustomIconBotton(
            onPressed: () {
              setState(() {
                _isPreviewMode = !_isPreviewMode;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(milliseconds: 1200),
                  content: Text(_isPreviewMode ? "Preview Mode Active" : "Editing Mode Active"),
                ),
              );
            },
            icon: _isPreviewMode ? Icons.edit_outlined : Icons.visibility_outlined,
            color: _isPreviewMode ? _selectedColor : null,
            iconColor: _isPreviewMode ? const Color(0xFF252525) : null,
          ),
          const SizedBox(width: 12),
          CustomIconBotton(
            onPressed: _saveNote,
            icon: Icons.save_outlined,
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Editor / Preview text content
            Expanded(
              child: _isPreviewMode ? _buildPreviewView() : _buildEditorView(),
            ),

            // Fixed Color Selector Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: AppColors.primary,
              child: Row(
                children: [
                  Text(
                    "Color:",
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 38,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: AppColors.noteColors.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final color = AppColors.noteColors[index];
                          final isSelected = _selectedColor.toARGB32() == color.toARGB32();
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Colors.white : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: color.withValues(alpha: 0.6),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
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

            // Interactive Formatting Toolbar matching Editor screenshot
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                border: Border(
                  top: BorderSide(color: Color(0xFF333333), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _ToolbarIcon(
                    icon: Icons.format_bold,
                    tooltip: "Bold",
                    onPressed: () => _formatWrap('**', '**'),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_italic,
                    tooltip: "Italic",
                    onPressed: () => _formatWrap('*', '*'),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_underlined,
                    tooltip: "Underline",
                    onPressed: () => _formatWrap('__', '__'),
                  ),
                  _ToolbarIcon(
                    icon: Icons.link,
                    tooltip: "Link",
                    onPressed: _insertLink,
                  ),
                  _ToolbarIcon(
                    icon: Icons.title,
                    tooltip: "Heading",
                    onPressed: () => _formatLinePrefix('# '),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_list_bulleted,
                    tooltip: "Bullet list",
                    onPressed: () => _formatLinePrefix('- '),
                  ),
                  _ToolbarIcon(
                    icon: Icons.code,
                    tooltip: "Code",
                    onPressed: () => _formatWrap('`', '`'),
                  ),
                  _ToolbarIcon(
                    icon: Icons.format_quote,
                    tooltip: "Quote",
                    onPressed: () => _formatLinePrefix('> '),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _titleController,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: "Title",
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFF9A9A9A),
                fontSize: 34,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
            maxLines: null,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentController,
            style: GoogleFonts.nunito(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 20,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: "Type something...",
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFF9A9A9A),
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
            ),
            maxLines: null,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewView() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _selectedColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _selectedColor, width: 1),
            ),
            child: Text(
              "PREVIEW",
              style: GoogleFonts.nunito(
                color: _selectedColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title.isEmpty ? "Untitled Note" : title,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),
          if (content.isEmpty)
            Text(
              "No content written yet.",
              style: GoogleFonts.nunito(
                color: Colors.white38,
                fontSize: 18,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            SelectableText.rich(
              _contentController.buildTextSpan(
                context: context,
                style: GoogleFonts.nunito(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 20,
                  height: 1.5,
                ),
                withComposing: false,
              ),
            ),
        ],
      ),
    );
  }
}

class _ToolbarIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ToolbarIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white70, size: 20),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
      ),
    );
  }
}
