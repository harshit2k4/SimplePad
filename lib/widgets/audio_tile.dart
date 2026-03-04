import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../controllers/note_controller.dart';

class AudioTile extends StatefulWidget {
  final String filePath;
  final VoidCallback onDelete;

  const AudioTile({super.key, required this.filePath, required this.onDelete});

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  final AudioPlayer player = AudioPlayer();
  final NoteController controller = Get.find();

  PlayerState playerState = PlayerState.stopped;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });
    player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });
    player.onPlayerStateChanged.listen((s) {
      if (mounted) setState(() => playerState = s);
    });

    ever(controller.currentPlayingPath, (String path) {
      if (mounted &&
          path != widget.filePath &&
          playerState == PlayerState.playing) {
        player.stop();
      }
    });
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  String _formatTime(Duration d) {
    return "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    String name = widget.filePath.split('/').last;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => isExpanded = !isExpanded),
            leading: Icon(
              playerState == PlayerState.playing
                  ? Icons.pause_circle
                  : Icons.play_circle,
              color: Theme.of(context).colorScheme.primary,
              size: 36,
            ),
            title: Text(
              name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            trailing: IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 20,
              ),
              onPressed: widget.onDelete,
            ),
          ),
          if (isExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble(),
                      max: duration.inSeconds > 0
                          ? duration.inSeconds.toDouble()
                          : 1.0,
                      onChanged: (val) =>
                          player.seek(Duration(seconds: val.toInt())),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(position),
                        style: const TextStyle(fontSize: 11),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10, size: 22),
                            onPressed: () => player.seek(
                              Duration(seconds: position.inSeconds - 10),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              playerState == PlayerState.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () {
                              if (playerState == PlayerState.playing) {
                                player.pause();
                              } else {
                                controller.stopAllAudio(widget.filePath);
                                player.play(DeviceFileSource(widget.filePath));
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.stop, size: 22),
                            onPressed: () => player.stop(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.forward_10, size: 22),
                            onPressed: () => player.seek(
                              Duration(seconds: position.inSeconds + 10),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatTime(duration),
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
