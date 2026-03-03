import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/note_model.dart';

class NoteController extends GetxController {
  // This list will hold all our notes
  var notes = <NoteModel>[].obs;

  // This is our Hive box
  late Box<NoteModel> notesBox;

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
  }

  // Function to add a new note
  void addNote(NoteModel note) {
    notesBox.put(note.id, note);
    loadNotes();
  }

  // Function to delete a note
  void deleteNote(String id) {
    notesBox.delete(id);
    loadNotes();
  }
}
