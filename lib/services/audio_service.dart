import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

class AudioService {
  final AudioRecorder audioRecorder = AudioRecorder();

  // This function starts recording a voice note
  Future<void> startRecording() async {
    // Check if the app has permission to use the microphone
    if (await audioRecorder.hasPermission()) {
      // Get a safe folder to save the audio file
      final directory = await getApplicationDocumentsDirectory();
      String fileName =
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      String path = '${directory.path}/$fileName';

      // Start recording with default settings
      const config = RecordConfig();
      await audioRecorder.start(config, path: path);
    }
  }

  // This function stops recording and returns the file path
  Future<String?> stopRecording() async {
    final path = await audioRecorder.stop();
    return path;
  }

  // This function allows the user to pick an audio file from their phone
  Future<String?> pickAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
    );

    if (result != null && result.files.single.path != null) {
      return result.files.single.path;
    }
    return null;
  }
}
