import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simplepad/services/audio_service.dart';
import 'package:simplepad/widgets/audio_tile.dart';
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
  late int selectedColorValue;

  final AudioService audioService = AudioService();
  bool isRecording = false;

  List<Map<String, dynamic>> blocks = [];
  List<TextEditingController> textControllers = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? '');
    selectedColorValue = widget.note?.colorValue ?? 0;

    // Initialize Blocks and their Controllers
    if (widget.note != null && widget.note!.blocks.isNotEmpty) {
      blocks = widget.note!.blocks
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      for (var block in blocks) {
        if (block['type'] == 'text') {
          textControllers.add(TextEditingController(text: block['content']));
        }
      }
    } else {
      // Start with one empty text block for a new note
      blocks = [
        {'type': 'text', 'content': ''},
      ];
      textControllers.add(TextEditingController());
    }
  }

  // Helper to place audio and a new text area below it
  void addAudioBlock(String path) {
    setState(() {
      blocks.add({'type': 'audio', 'content': path});
      blocks.add({'type': 'text', 'content': ''});
      textControllers.add(TextEditingController());
    });
  }

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
    // Synchronize text controllers into the blocks list
    int textIdx = 0;
    for (var block in blocks) {
      if (block['type'] == 'text') {
        block['content'] = textControllers[textIdx].text;
        textIdx++;
      }
    }

    final id =
        widget.note?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final note = NoteModel(
      id: id,
      title: titleController.text,
      blocks: blocks,
      dateTime: DateTime.now(),
      colorValue: selectedColorValue,
      audioPaths: blocks
          .where((b) => b['type'] == 'audio')
          .map((b) => b['content'] as String)
          .toList(),
    );

    if (widget.note == null) {
      controller.addNote(note);
    } else {
      controller.updateNote(note);
    }

    Get.back(); // Always go back after saving
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var ctrl in textControllers) {
      ctrl.dispose();
    }
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return PopScope(
  //     canPop: false, // Prevent going back immediately
  //     onPopInvokedWithResult: (didPop, result) async {
  //       if (didPop) return;
  //       _handleBackAction(); // Show alert
  //     },
  //     child: Scaffold(
  //       backgroundColor: selectedColorValue == 0
  //           ? Theme.of(context).colorScheme.surface
  //           : Color(selectedColorValue).withOpacity(0.3),
  //       appBar: AppBar(
  //         elevation: 0,
  //         backgroundColor: Colors.transparent,
  //         title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
  //         actions: [
  //           IconButton(icon: const Icon(Icons.check), onPressed: saveNote),
  //         ],
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevents default back behavior to let us handle it
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackAction(); // Handles hardware back and swipe gestures
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? 'New Note' : 'Edit Note'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBackAction, // Handles tap on back icon
          ),
          actions: [
            IconButton(icon: const Icon(Icons.check), onPressed: saveNote),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: blocks.length + 2, // +1 for the Title field
                itemBuilder: (context, index) {
                  // Point 1: Added extra space at the bottom
                  if (index == blocks.length + 1) {
                    return const SizedBox(height: 150);
                  }
                  if (index == 0) {
                    return TextField(
                      controller: titleController,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                      ),
                    );
                  }

                  int blockIndex = index - 1;
                  var block = blocks[blockIndex];

                  if (block['type'] == 'text') {
                    // Find the matching controller for this text block
                    int ctrlIndex = blocks
                        .sublist(0, blockIndex)
                        .where((b) => b['type'] == 'text')
                        .length;
                    return TextField(
                      controller: textControllers[ctrlIndex],
                      maxLines: null,
                      style: const TextStyle(fontSize: 18, height: 1.5),
                      decoration: const InputDecoration(
                        hintText: 'Type something...',
                        border: InputBorder.none,
                      ),
                    );
                  } else {
                    return AudioTile(
                      filePath: block['content'],
                      onDelete: () {
                        setState(() {
                          blocks.removeAt(blockIndex);
                        });
                      },
                    );
                  }
                },
              ),
            ),

            // Floating Bar
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
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isRecording ? Icons.stop : Icons.mic,
                            color: isRecording ? Colors.red : Colors.blueAccent,
                          ),
                          onPressed: () async {
                            if (isRecording) {
                              String? path = await audioService.stopRecording();
                              if (path != null) {
                                addAudioBlock(path);
                                setState(() => isRecording = false);
                              }
                            } else {
                              await audioService.startRecording();
                              setState(() => isRecording = true);
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.attach_file,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () async {
                            String? path = await audioService.pickAudioFile();
                            if (path != null) addAudioBlock(path);
                          },
                        ),
                        const VerticalDivider(
                          width: 20,
                          indent: 15,
                          endIndent: 15,
                        ),
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: noteColors.length,
                            itemBuilder: (context, index) {
                              final color = noteColors[index];
                              return GestureDetector(
                                onTap: () => setState(
                                  () => selectedColorValue = color.value,
                                ),
                                child: Container(
                                  width: 40,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color == Colors.transparent
                                        ? Colors.grey.withOpacity(0.3)
                                        : color,
                                    shape: BoxShape.circle,
                                    border: selectedColorValue == color.value
                                        ? Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          )
                                        : null,
                                  ),
                                  child: color == Colors.transparent
                                      ? const Icon(
                                          Icons.palette_outlined,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBackAction() {
    if (_isNoteChanged()) {
      Get.defaultDialog(
        title: "Save Changes?",
        middleText: "You have unsaved work. Would you like to save it?",
        textConfirm: "Save",
        textCancel: "Discard",
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back(); // Close dialog
          saveNote(); // Save and return to home
        },
        onCancel: () {
          Get.back(); // Close dialog
          Get.back(); // Discard changes and return to home
        },
      );
    } else {
      Get.back(); // No changes, just go back
    }
  }

  bool _isNoteChanged() {
    // Check Title
    if (titleController.text != (widget.note?.title ?? '')) return true;

    // Check Color
    if (selectedColorValue != (widget.note?.colorValue ?? 0)) return true;

    // Normalize comparison: a new note has one empty text block
    List<Map<dynamic, dynamic>> original =
        widget.note?.blocks ??
        [
          {'type': 'text', 'content': ''},
        ];

    // Check Block Count
    if (blocks.length != original.length) return true;

    // Check Block Contents
    int textIdx = 0;
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i]['type'] != original[i]['type']) return true;

      if (blocks[i]['type'] == 'text') {
        if (textControllers[textIdx].text != original[i]['content'])
          return true;
        textIdx++;
      } else {
        // Compare audio paths
        if (blocks[i]['content'] != original[i]['content']) return true;
      }
    }

    return false;
  }
}
