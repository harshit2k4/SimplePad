import 'package:hive/hive.dart';

/// To generate the Hive adapter code run the following command
/// dart run build_runner build
part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime dateTime;

  @HiveField(4)
  int colorValue;

  // This will store the file paths of the voice recordings
  @HiveField(5)
  List<String> audioPaths;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.dateTime,
    required this.colorValue,
    required this.audioPaths,
  });
}
