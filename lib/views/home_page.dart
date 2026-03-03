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
    // Put the controller into GetX memory
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
              Tab(text: 'All Notes'),
              Tab(text: 'Settings'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildNoteGrid(controller), // Move the existing Obx grid here
            const SettingsPage(),
          ],
        ),
        floatingActionButton: FloatingActionButton.large(
          // Expressive FAB
          onPressed: () => Get.to(() => const NoteEditorPage()),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  // Helper method to keep code modular
  Widget _buildNoteGrid(NoteController controller) {
    return Obx(() {
      if (controller.notes.isEmpty) {
        return const Center(child: Text('No notes yet.'));
      }
      return MasonryGridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(12),
        itemCount: controller.notes.length,
        itemBuilder: (context, index) {
          final note = controller.notes[index];
          return Card(
            // Use the note's color or a default surface color
            color: note.colorValue == 0 ? null : Color(note.colorValue),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    note.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    note.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
