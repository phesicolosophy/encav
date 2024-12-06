import 'package:encav/features/encypt_audio_video/domain/entities/encrypted_audio_video.dart';
import 'package:flutter/material.dart';

/// Display all not encrypted audio and video.
class DisplayEncrypted extends StatefulWidget {
  const DisplayEncrypted({
    super.key,
    required this.audio,
    required this.video,
  });

  final List<EncryptedAudioVideo> audio;
  final List<EncryptedAudioVideo> video;

  @override
  State<DisplayEncrypted> createState() => _DisplayEncryptedState();
}

class _DisplayEncryptedState extends State<DisplayEncrypted> {
  int numOfAudioEncryptedFileCheked = 0;
  int numOfVideoEncryptedFileCheked = 0;

  bool checkAllAudio = false;
  bool checkAllVideo = false;

  void countAudioEncryptCheked() {
    numOfAudioEncryptedFileCheked =
        widget.audio.where((toElement) => toElement.isCheck == true).length;
  }

  void countVideoEncryptCheked() {
    numOfVideoEncryptedFileCheked =
        widget.video.where((toElement) => toElement.isCheck == true).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //_% Display audio
          if (widget.audio.isNotEmpty)
            Row(
              children: [
                //_% Check all audio
                Checkbox(
                  value: checkAllAudio,
                  onChanged: (onCheckAllAudio) {
                    checkAllAudio = onCheckAllAudio ?? false;
                    for (var aud in widget.audio) {
                      aud.isCheck = onCheckAllAudio ?? false;
                    }
                    countAudioEncryptCheked();
                    setState(() {});
                  },
                ),
                const Text('Add all audio'),
                const Spacer(),
                //_% Number of encrypting files / Total files
                Row(
                  children: [
                    Text('$numOfAudioEncryptedFileCheked'),
                    const Text('/'),
                    Text('${widget.audio.length}'),
                  ],
                ),
                //_% Clear button
                IconButton.filled(
                  tooltip: 'clear',
                  onPressed: () {
                    widget.audio.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear_all),
                )
              ],
            ),
          widget.audio.isEmpty
              ? const Center(child: Text('none found'))
              : Flexible(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100.0,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: widget.audio.length,
                    itemBuilder: (context, index) => FittedBox(
                      child: IconButton.filled(
                        onPressed: () {
                          widget.audio[index].isCheck = !widget.audio[index].isCheck;
                          countAudioEncryptCheked();
                          setState(() {});
                        },
                        icon: Row(
                          children: [
                            Checkbox(value: widget.audio[index].isCheck, onChanged: null),
                            Text(widget.audio[index].name)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
          const Divider(),
          //_% Display video
          if (widget.video.isNotEmpty)
            Row(
              children: [
                //_% Check all video
                Checkbox(
                  value: checkAllVideo,
                  onChanged: (onCheckAllVideo) {
                    checkAllVideo = onCheckAllVideo ?? false;
                    for (var vid in widget.video) {
                      vid.isCheck = onCheckAllVideo ?? false;
                    }
                    countVideoEncryptCheked();
                    setState(() {});
                  },
                ),
                const Text('Add all video'),
                const Spacer(),
                //_% Number of encrypting files / Total files
                Row(
                  children: [
                    Text('$numOfVideoEncryptedFileCheked'),
                    const Text('/'),
                    Text('${widget.video.length}'),
                  ],
                ),
                //_% Clear button
                IconButton.filled(
                  tooltip: 'clear',
                  onPressed: () {
                    widget.video.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.clear_all),
                )
              ],
            ),
          widget.video.isEmpty
              ? const Center(child: Text('none found'))
              : Flexible(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 100.0,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: widget.video.length,
                    itemBuilder: (context, index) => FittedBox(
                      child: IconButton.filled(
                        onPressed: () {
                          widget.video[index].isCheck = !widget.video[index].isCheck;
                          countVideoEncryptCheked();
                          setState(() {});
                        },
                        icon: Row(
                          children: [
                            Checkbox(value: widget.video[index].isCheck, onChanged: null),
                            Text(widget.video[index].name)
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}