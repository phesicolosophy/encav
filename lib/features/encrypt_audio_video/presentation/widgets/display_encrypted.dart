import 'package:encav/features/encrypt_audio_video/domain/entities/encrypted_audio_video.dart';
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
  int numOfAudioEncryptedFileChecked = 0;
  int numOfVideoEncryptedFileChecked = 0;

  bool checkAllAudio = false;
  bool checkAllVideo = false;

  void countAudioEncryptChecked() {
    numOfAudioEncryptedFileChecked =
        widget.audio.where((toElement) => toElement.isCheck == true).length;
  }

  void countVideoEncryptChecked() {
    numOfVideoEncryptedFileChecked =
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
                    countAudioEncryptChecked();
                    setState(() {});
                  },
                ),
                const Text('Add all audio'),
                const Spacer(),
                //_% Number of encrypting files / Total files
                Row(
                  children: [
                    Text('$numOfAudioEncryptedFileChecked'),
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
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      // if widget.audio.length = 1 the IconButton.filled is to big.
                      // Todo FixMe find another way for the widget to be user friendly.
                      maxCrossAxisExtent: 50 + 500 / (widget.audio.length == 1 ? 2 : widget.audio.length), // 100.0,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: widget.audio.length,
                    itemBuilder: (context, index) => FittedBox(
                      child: IconButton.filled(
                        onPressed: () {
                          widget.audio[index].isCheck = !widget.audio[index].isCheck;
                          countAudioEncryptChecked();
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
                    countVideoEncryptChecked();
                    setState(() {});
                  },
                ),
                const Text('Add all video'),
                const Spacer(),
                //_% Number of encrypting files / Total files
                Row(
                  children: [
                    Text('$numOfVideoEncryptedFileChecked'),
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
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 50 + 500 / (widget.video.length == 1 ? 2 : widget.video.length), //100.0,
                      childAspectRatio: 1.6,
                    ),
                    itemCount: widget.video.length,
                    itemBuilder: (context, index) => FittedBox(
                      child: IconButton.filled(
                        onPressed: () {
                          widget.video[index].isCheck = !widget.video[index].isCheck;
                          countVideoEncryptChecked();
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
