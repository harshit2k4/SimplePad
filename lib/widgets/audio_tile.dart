import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioTile extends StatefulWidget {
  final String filePath;
  final VoidlongCallback onDelete;

  const AudioTile({super.key, required this.filePath, required this.onDelete});

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  // play or pause the audio
  void togglePlay() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.play(DeviceFileSource(widget.filePath));
    }
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extract the file name from the path to show the user
    String name = widget.filePath.split('/').last;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: IconButton(
          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          onPressed: togglePlay,
        ),
        title: Text(name, style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: widget.onDelete,
        ),
      ),
    );
  }
}

typedef VoidlongCallback = void Function();
