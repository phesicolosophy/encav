import 'package:encav/constants/constants_themes.dart';
import 'package:encav/features/encypt_audio_video/presentation/pages/encrypt_audio_video_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const EncAV());
}

class EncAV extends StatelessWidget {
  const EncAV({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ConstantsThemes.themeLight,
      home: const EncryptAudioVideoPage(),
    );
  }
}