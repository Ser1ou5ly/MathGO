import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class BgmProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  BgmProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _player.setAsset('assets/song/BabyShark.mp3'); // your audio path
    _player.setLoopMode(LoopMode.all);
    _player.setVolume(0.5);
    await _player.play();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _player.setVolume(_isMuted ? 0.0 : 0.5);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
