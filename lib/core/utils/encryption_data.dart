import 'dart:developer' as dev show log;

import 'dart:io';
import 'dart:isolate';

import 'package:encav/constants/constants_enc_key.dart';
import 'package:encrypt/encrypt.dart';
import 'package:path/path.dart' as p show join, hash, basename;

class EncryptData {
  /// Encrypt audio or video files on separate thread before playing them.
  ///
  /// {@tool snippet}
  ///
  /// [filePath] is the relative path of the audio or video to the current directory.
  ///
  /// To encrypt song.mp3 file in audio directory of the current project:
  /// ``` dart
  /// await EncryptData.encryptAV('audio/song.mp3');
  /// ```
  /// {@end-tool}
  static Future<void> encryptAV(String filePath) async {
    final File file = File(filePath);
    final List<String> splitFilePath = filePath.split('/');
    final String hashFileName = p.hash(filePath).toString();
    final String encryptedPath =
        p.join(splitFilePath.sublist(0, splitFilePath.length - 1).join('/'), hashFileName);
    final File encryptedFile = File(encryptedPath);
    print('${splitFilePath[splitFilePath.length - 1]} -> $hashFileName');

    final Key key = Key.fromUtf8(EncConstant.key);
    final IV iv = IV.fromUtf8(EncConstant.iv);

    final encrypter = Encrypter(AES(key));
    try {
      await Isolate.run(() {
        final Encrypted enc = encrypter.encryptBytes(file.readAsBytesSync(), iv: iv);
        encryptedFile.writeAsBytesSync(enc.bytes, mode: FileMode.writeOnly);
      });
    } catch (_) {
      dev.log('Encryption file error using Isolate on encryptAV', name: 'EncryptData');
    }
  }

  /// Decrypt audio or video files on separate thread before playing them.
  ///
  /// {@tool snippet}
  /// [filePath] is the relative path of the audio or video to the current directory.
  ///
  /// To decrypt song.mp3 file in audio directory of the current project:
  ///
  /// ``` dart
  /// await EncryptData.decryptAV('audio/ezfd123dfds', '.mp3');
  /// await EncryptData.decryptAV('video/ezfd123dfds', '.mp4');
  /// ```
  /// {@end-tool}
  static Future<String> decryptAV(String filePath, String ext) async {
    final file = File(filePath);
    String decFileName = p.basename(filePath);
    String decFilePath = p.join(Directory.systemTemp.path, decFileName + ext);
    final decryptedFile = File(decFilePath);

    final key = Key.fromUtf8(EncConstant.key);
    final iv = IV.fromUtf8(EncConstant.iv);

    // Todo improve the Encrypter (read the source file)
    final encrypter = Encrypter(AES(key));
    try {
      await Isolate.run(() {
        final red = Encrypted(file.readAsBytesSync());
        final List<int> dec = encrypter.decryptBytes(red, iv: iv);

        decryptedFile.writeAsBytesSync(dec);
      });
    } catch (_) {
      dev.log('Decryption file error using Isolate on decryptAV', name: 'EncryptData');
    }
    return decryptedFile.path;
  }
}
