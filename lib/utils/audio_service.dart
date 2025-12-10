import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playMoveSound() async {
    try {
      await _player.play(AssetSource('audio/move-self.mp3'),
          mode: PlayerMode.lowLatency);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playCaptureSound() async {
    try {
      await _player.play(AssetSource('audio/capture.mp3'),
          mode: PlayerMode.lowLatency);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playCheckSound() async {
    try {
      await _player.play(AssetSource('audio/move-check.mp3'),
          mode: PlayerMode.lowLatency);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playGameStartSound() async {
    try {
      await _player.play(AssetSource('audio/game-start.mp3'),
          mode: PlayerMode.lowLatency);
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> playGameOverSound() async {
    try {
      await _player.play(AssetSource('audio/game-end.mp3'),
          mode: PlayerMode.lowLatency);
    } catch (e) {
      // Ignore errors
    }
  }
}
