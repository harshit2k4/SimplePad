import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:simplepad/views/note_editor_page.dart';
import 'package:simplepad/views/settings_page.dart';
import '../controllers/note_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final NoteController controller = Get.put(NoteController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'SimplePad',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Notes'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildNoteList(controller), const SettingsPage()],
        ),
        floatingActionButton: FloatingActionButton.large(
          onPressed: () => Get.to(() => const NoteEditorPage()),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildNoteList(NoteController controller) {
    return Column(
      children: [
        // Glassmorphism Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: TextField(
                  onChanged: (value) => controller.filterNotes(value),
                  decoration: const InputDecoration(
                    hintText: 'Search notes...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          ),
        ),

        // The Grid
        Expanded(
          child: Obx(() {
            if (controller.filteredNotes.isEmpty) {
              return const Center(child: Text('No notes found.'));
            }
            return MasonryGridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(12),
              itemCount: controller.filteredNotes.length,
              itemBuilder: (context, index) {
                final note = controller.filteredNotes[index];

                Color noteColor = note.colorValue == 0
                    ? Theme.of(context).colorScheme.surfaceVariant
                    : Color(note.colorValue).withOpacity(0.5);

                return GestureDetector(
                  onTap: () {
                    // Navigate to editor and pass the selected note
                    Get.to(() => NoteEditorPage(note: note));
                  },
                  onLongPress: () {
                    // Show a simple delete confirmation
                    _showDeleteDialog(context, controller, note.id);
                  },
                  child: Card(
                    color: noteColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: const BorderSide(color: Colors.black12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            note.content,
                            style: const TextStyle(fontSize: 14),
                            maxLines: 6,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    NoteController controller,
    String id,
  ) {
    Get.defaultDialog(
      title: "Delete Note",
      middleText: "Are you sure you want to remove this note?",
      textConfirm: "Delete",
      confirmTextColor: Colors.white,
      onConfirm: () {
        controller.deleteNote(id);
        Get.back();
      },
      textCancel: "Cancel",
    );
  }
}
