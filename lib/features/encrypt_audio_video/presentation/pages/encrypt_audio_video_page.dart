import 'dart:io' show Directory, FileSystemEntityType;
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

import '../../../../core/utils/encryption_data.dart';
import '../../domain/entities/encrypted_audio_video.dart';
import '../widgets/add_key_iv.dart';
import '../widgets/display_encrypted.dart';
// refactor the code clean architecture

class EncryptAudioVideoPage extends StatefulWidget {
  const EncryptAudioVideoPage({super.key});

  @override
  State<EncryptAudioVideoPage> createState() => _EncryptAudioVideoPageState();
}

class _EncryptAudioVideoPageState extends State<EncryptAudioVideoPage> {
  List<EncryptedAudioVideo> audioFilesName = [];
  List<EncryptedAudioVideo> videoFilesName = [];

  bool searchSubDirectory = false;
  String searchFolder = '';
  List<String> directoryInSearchFolder = [];
  String currentDirectory = Directory.current.path;

  bool _isEncryption = false;

  Map<String, String> logEncryptedOldNewNames = {};

  @override
  void initState() {
    super.initState();
    getCurrentDirectory(searchFolder);
    getDirectoriesInSearchFolder();
    getAllAudioVideoFiles();
  }

  void getCurrentDirectory(String folder) {
    currentDirectory = p.join(currentDirectory, folder);
  }

  void getPreviousDirectory() {
    currentDirectory = Directory(currentDirectory).parent.path;
  }

  void getDirectoriesInSearchFolder() {
    directoryInSearchFolder.clear();
    // final nextDirectory = p.join(currentDirectory, directoryPath);
    final allFiles = Directory(currentDirectory).listSync();
    for (var file in allFiles) {
      if (file.statSync().type == FileSystemEntityType.directory) {
        final String baseName = file.path.split('/').last;
        directoryInSearchFolder.add(baseName);
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
        audioFilesName.add(EncryptedAudioVideo(name: baseName));
        continue;
      }
      if (baseName.endsWith('.mp4')) {
        videoFilesName.add(EncryptedAudioVideo(name: baseName));
      }
    }
    setState(() {});
  }

  void _showLogEncryptedOldNewNames() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ListView(
          shrinkWrap: true,
          children: List.generate(logEncryptedOldNewNames.length, (index) {
            final String newName = logEncryptedOldNewNames.values.toList()[index];
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${logEncryptedOldNewNames.keys.toList()[index]} ->',
                ),
                TextButton(
                  onPressed: () async {
                    Clipboard.setData(ClipboardData(text: newName));
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('Data copied to clipboard')));
                  },
                  child: Text(newName),
                )
              ],
            );
          }),
        ),
      ),
    );
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
                // Todo FixMe: temporally change from open directory to search button
                //_% Search button
                IconButton.filledTonal(
                  tooltip: 'search',
                  onPressed: () {
                    getAllAudioVideoFiles();
                  },
                  icon: const Icon(Icons.search),
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
                      getDirectoriesInSearchFolder();
                      setState(() {});
                    },
                    icon: const Icon(Icons.replay)),
                //_% Next
                DropdownButton<String>(
                  dropdownColor: Colors.green,
                  hint: const Text('Search in'),
                  items: List<DropdownMenuItem<String>>.generate(
                    directoryInSearchFolder.length,
                    (index) => DropdownMenuItem<String>(
                      value: directoryInSearchFolder[index],
                      child: Text(directoryInSearchFolder[index]),
                    ),
                  ),
                  onChanged: (onSelected) {
                    getCurrentDirectory(onSelected ?? '');
                    getDirectoriesInSearchFolder();
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
            Row(
              children: [
                //_% Search Sub-folders
                Checkbox(
                    value: searchSubDirectory,
                    onChanged: (onToggle) => setState(() {
                          searchSubDirectory = onToggle ?? false;
                        })),
                const Text('Search sub-folders'),
                const Spacer(),
                //_% Log encrypted old and new names
                IconButton.filled(
                    onPressed: _showLogEncryptedOldNewNames,
                    icon: const Icon(Icons.my_library_books_outlined))
              ],
            ),
            //_% Encryption button
            ElevatedButton(
              onPressed: () {
                logEncryptedOldNewNames.clear();
                setState(() => _isEncryption = true);
                Future.microtask(() async {
                  for (var aud in audioFilesName) {
                    // Todo Improve: in getAllAudioVideoFiles save the hole path not just the baseName
                    // Todo Improve: because when to encrypt you encrypt in same folder.
                    if (aud.isCheck) {
                      logEncryptedOldNewNames
                          .addAll(await EncryptData.encryptAV(p.join(currentDirectory, aud.name)));
                    }
                  }
                  for (var vid in videoFilesName) {
                    if (vid.isCheck) {
                      logEncryptedOldNewNames
                          .addAll(await EncryptData.encryptAV(p.join(currentDirectory, vid.name)));
                    }
                  }
                }).then((_) => setState(() => _isEncryption = false));
              },
              child: _isEncryption
                  ? const SizedBox.square(dimension: 16.0, child: CircularProgressIndicator())
                  : const Text('Encrypt'),
            ),
            //_% Decryption button
            ElevatedButton(
                onPressed: () {
                  // Todo implement
                  print(currentDirectory + '/1890350767');
                  EncryptData.decryptAV(currentDirectory + '/1890350767', '.mp3');
                },
                child: const Text('decrypt')),
            const SizedBox(height: 8.0),
          ],
        ));
  }
}
