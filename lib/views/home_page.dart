import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:simplepad/views/note_editor_page.dart';
import '../controllers/note_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Put the controller into GetX memory
    final NoteController controller = Get.put(NoteController());

    return Scaffold(
      appBar: AppBar(title: const Text('SimplePad'), centerTitle: true),
      // Obx makes the UI update automatically when notes change
      body: Obx(() {
        if (controller.notes.isEmpty) {
          return const Center(child: Text('No notes yet. Tap + to add one!'));
        }

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: MasonryGridView.count(
            crossAxisCount: 2, // Two columns
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: controller.notes.length,
            itemBuilder: (context, index) {
              final note = controller.notes[index];
              return Card(
                color: Color(note.colorValue),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        note.content,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const NoteEditorPage());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
