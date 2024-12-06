import 'dart:io' show Directory, FileSystemEntityType;
import 'package:path/path.dart' as p;

import 'package:flutter/material.dart';

import '../../../../core/utils/encryption_data.dart';
import '../../domain/entities/encrypted_audio_video.dart';
import '../widgests/add_key_iv.dart';
import '../widgests/display_encypted.dart';


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
        audioFilesName.add(EncryptedAudioVideo(name: baseName));
        continue;
      }
      if (baseName.endsWith('.mp4')) {
        videoFilesName.add(EncryptedAudioVideo(name: baseName));
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