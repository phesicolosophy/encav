import 'dart:io';

import 'package:encav/constants/constants_themes.dart';
import 'package:encav/ecryption/encryption_data.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as p show join;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ConstantsThemes.themeLight,
      home: const EncriptAudio(),
    );
  }
}

class EncriptAudio extends StatefulWidget {
  const EncriptAudio({super.key});

  @override
  State<EncriptAudio> createState() => _EncriptAudioState();
}

class _EncriptAudioState extends State<EncriptAudio> {
  List<FileModel> audioFilesName = [];
  List<FileModel> videoFilesName = [];

  bool searchSubDirectory = false;
  String searchFolder = '';
  List<String> directoryInSearchFloder = [];
  String currentDirectory = Directory.current.path;

  bool _isEncryption = false;

  @override
  void initState() {
    super.initState();
    getCurrentDirectory(searchFolder);
    getDirectoriesInSearchFloder();
    getAllAudioVideoFiles();
  }

  void getCurrentDirectory(String folder) {
    currentDirectory = p.join(currentDirectory, folder);
  }

  void getPreviousDirectory() {
    currentDirectory = Directory(currentDirectory).parent.path;
  }

  void getDirectoriesInSearchFloder() {
    directoryInSearchFloder.clear();
    // final nextDirectory = p.join(currentDirectory, directoryPath);
    final allFiles = Directory(currentDirectory).listSync();
    for (var file in allFiles) {
      if (file.statSync().type == FileSystemEntityType.directory) {
        final String baseName = file.path.split('/').last;
        directoryInSearchFloder.add(baseName);
      }
    }
  }

  void ffff() {
    audioFilesName.clear();
    setState(() {});
  }

  void getAllAudioVideoFiles() {
    audioFilesName.clear();
    videoFilesName.clear();
    // final nextDirectory = p.join(currentDirectory, directoryPath);
    final allFiles = Directory(currentDirectory).listSync();
    for (var file in allFiles) {
      if (searchSubDirectory) {
        if (file.statSync().type == FileSystemEntityType.directory) {
          getCurrentDirectory(file.path);
          getAllAudioVideoFiles();
          getPreviousDirectory();
        }
      }
      if (file.statSync().type != FileSystemEntityType.file) continue;
      final String baseName = file.path.split('/').last;
      if (baseName.endsWith('.mp3')) {
        audioFilesName.add(FileModel(name: baseName));
        continue;
      }
      if (baseName.endsWith('.mp4')) {
        videoFilesName.add(FileModel(name: baseName));
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Encrypt Audio && Video'),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // textDirection: TextDirection.rtl,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Todo improve by saving and loading from file and show them in drop menu.
            //_% Heder [add key, open directory]
            const SizedBox(height: 8.0),
            Row(
              children: [
                const Spacer(flex: 5),
                //_% Add new Key and IV
                const AddKeyIV(),
                const Spacer(flex: 2),
                // Todo FixMe: temporarely change from open directory to search button
                //_% Search button
                IconButton.filledTonal(
                  tooltip: 'search',
                  onPressed: () {
                    getAllAudioVideoFiles();
                  },
                  icon: const Icon(Icons.folder),
                ),
                const Spacer(flex: 2),
              ],
            ),
            //_% Display the current directory [previous, next]
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //_% Previous
                IconButton.filled(
                    onPressed: () {
                      getPreviousDirectory();
                      getDirectoriesInSearchFloder();
                      setState(() {});
                    },
                    icon: const Icon(Icons.replay)),
                //_% Next
                DropdownButton<String>(
                  dropdownColor: Colors.green,
                  hint: const Text('Search in'),
                  items: List<DropdownMenuItem<String>>.generate(
                    directoryInSearchFloder.length,
                    (index) => DropdownMenuItem<String>(
                      value: directoryInSearchFloder[index],
                      child: Text(directoryInSearchFloder[index]),
                    ),
                  ),
                  onChanged: (onSelected) {
                    getCurrentDirectory(onSelected ?? '');
                    getDirectoriesInSearchFloder();
                    setState(() {});
                  },
                ),
              ],
            ),
            //_% Display the absolute path
            Text(currentDirectory),
            //_% Display all audio and video files that are not encrypted
            Expanded(
              child: DisplayEncrypted(audio: audioFilesName, video: videoFilesName),
            ),
            //_% Search Subfolders
            Row(
              children: [
                Checkbox(
                    value: searchSubDirectory,
                    onChanged: (onToggle) => setState(() {
                          searchSubDirectory = onToggle ?? false;
                        })),
                const Text('Search subfolders')
              ],
            ),
            //_% Encyption button
            ElevatedButton(
              onPressed: () {
                setState(() => _isEncryption = true);
                Future.microtask(() async {
                  for (var aud in audioFilesName) {
                    // Todo Improve: in getAllAudioVideoFiles save the hole path not just the baseName
                    // Todo Improve: because when to encrypt you encript in smae folder.
                    if (aud.isCheck)
                      await EncryptData.encryptAV(p.join(currentDirectory, aud.name));
                  }
                  for (var vid in videoFilesName) {
                    if (vid.isCheck)
                      await EncryptData.encryptAV(p.join(currentDirectory, vid.name));
                  }
                }).then((_) => setState(() => _isEncryption = false));
              },
              child: _isEncryption
                  ? const CircularProgressIndicator()
                  : const Text('Encrypt'),
            ),
            ElevatedButton(onPressed: () {
              print(currentDirectory+'/1890350767');
              EncryptData.decryptAV(currentDirectory+'/1890350767', '.mp3');
            }, child: Text('decrypt')),
            const SizedBox(height: 8.0),
          ],
        ));
  }
}

/// Display all not encrypted audio and video.
class DisplayEncrypted extends StatefulWidget {
  const DisplayEncrypted({
    super.key,
    required this.audio,
    required this.video,
  });

  final List<FileModel> audio;
  final List<FileModel> video;

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

/// Add new key and IV to store and dis^lay them in drop menu.
class AddKeyIV extends StatelessWidget {
  const AddKeyIV({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Add Key and IV encryption'),
        IconButton(onPressed: () {}, icon: const Icon(Icons.add, color: Colors.white))
      ],
    );
  }
}

class FileModel {
  String name;
  bool isCheck;
  FileModel({required this.name, this.isCheck = false});
}
