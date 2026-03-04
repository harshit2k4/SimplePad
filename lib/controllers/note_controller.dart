import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteController extends GetxController {
  // This list will hold all our notes
  var notes = <NoteModel>[].obs;
  // This list will change as the user types in search
  var filteredNotes = <NoteModel>[].obs;

  // This is our Hive box
  late Box<NoteModel> notesBox;

  // Track the current playing file path
  var currentPlayingPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get the box we opened in main.dart
    notesBox = Hive.box<NoteModel>('notes_box');
    // Load existing notes into our list
    loadNotes();
  }

  // Function to refresh the list from Hive
  void loadNotes() {
    notes.assignAll(notesBox.values.toList());
    // Initially, filtered notes are just all notes
    filteredNotes.assignAll(notes);
  }

  // Search Function
  void filterNotes(String query) {
    if (query.isEmpty) {
      filteredNotes.assignAll(notes);
    } else {
      final lowerQuery = query.toLowerCase();
      filteredNotes.assignAll(
        notes.where((note) {
          bool titleMatch = note.title.toLowerCase().contains(lowerQuery);
          // Search through blocks for text matches
          bool contentMatch = note.blocks.any(
            (block) =>
                block['type'] == 'text' &&
                block['content'].toString().toLowerCase().contains(lowerQuery),
          );
          return titleMatch || contentMatch;
        }).toList(),
      );
    }
  }

  void stopAllAudio(String path) {
    currentPlayingPath.value = path;
  }

  void addNote(NoteModel note) {
    notesBox.put(note.id, note);
    loadNotes();
  }

  // Function to delete a note
  void deleteNote(String id) {
    notesBox.delete(id);
    loadNotes(); // Refresh the list
  }

  // Function to update a note
  void updateNote(NoteModel note) {
    notesBox.put(note.id, note); // Overwrites the old note with the same ID
    loadNotes(); // Refresh the list
  }
}
