import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';
import '../models/note_model.dart';

class NoteEditorPage extends StatefulWidget {
  final NoteModel? note;
  const NoteEditorPage({super.key, this.note});

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final NoteController controller = Get.find<NoteController>();
  late TextEditingController titleController;
  late TextEditingController contentController;
  late int selectedColorValue;

  @override
  void initState() {
    super.initState();
    // Initialize with existing note data if editing
    titleController = TextEditingController(text: widget.note?.title ?? '');
    contentController = TextEditingController(text: widget.note?.content ?? '');
    selectedColorValue = widget.note?.colorValue ?? 0;
  }

  // Simple list of soft Material 3 colors
  final List<Color> noteColors = [
    Colors.transparent,
    Colors.red.shade100,
    Colors.orange.shade100,
    Colors.yellow.shade100,
    Colors.green.shade100,
    Colors.blue.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
  ];

  void saveNote() {
    if (titleController.text.isEmpty && contentController.text.isEmpty) {
      Get.back();
      return;
    }

    // Keep the old ID if editing, otherwise create a new one
    final String noteId =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();

    final updatedNote = NoteModel(
      id: noteId,
      title: titleController.text,
      content: contentController.text,
      dateTime: DateTime.now(),
      colorValue: selectedColorValue,
      audioPaths: widget.note?.audioPaths ?? [], // Keep existing recordings
    );

    if (widget.note == null) {
      controller.addNote(updatedNote);
    } else {
      controller.updateNote(updatedNote);
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColorValue == 0
          ? Theme.of(context).colorScheme.surface
          : Color(selectedColorValue).withOpacity(0.3), // Soft background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text('Edit Note'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: saveNote),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Title',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  maxLines: null,
                  style: const TextStyle(fontSize: 18, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: 'Type something amazing...',
                    border: InputBorder.none,
                  ),
                ),
                const SizedBox(height: 100), // Space for the bottom bar
              ],
            ),
          ),

          // Floating Glassmorphism Color Picker
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: noteColors.length,
                    itemBuilder: (context, index) {
                      final color = noteColors[index];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => selectedColorValue = color.value),
                        child: Container(
                          width: 45,
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: color == Colors.transparent
                                ? Colors.grey.withOpacity(0.3)
                                : color,
                            shape: BoxShape.circle,
                            border: selectedColorValue == color.value
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: color == Colors.transparent
                              ? const Icon(Icons.palette_outlined)
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
