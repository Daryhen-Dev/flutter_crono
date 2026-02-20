import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;
  AudioService._();

  final _player = AudioPlayer();
  final _musicPlayer = AudioPlayer();
  final _previewPlayer = AudioPlayer();
  Uint8List? _shortBeep;
  Uint8List? _longBeep;
  String? _currentMusic;
  bool _playerContextSet = false;

  static const _musicVolume = 1.0;
  static const _duckedVolume = 0.25;

  void _ensureGenerated() {
    _shortBeep ??= _generateWav(0.12, 880);
    _longBeep ??= _generateWav(0.45, 880);
  }

  /// Configure beep player to not steal audio focus from music player.
  Future<void> _ensurePlayerContext() async {
    if (_playerContextSet) return;
    _playerContextSet = true;
    await _player.setAudioContext(
      AudioContext(
        android: const AudioContextAndroid(audioFocus: AndroidAudioFocus.none),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  /// Play short beep with music ducking.
  Future<void> playShortBeep() async {
    _ensureGenerated();
    if (_currentMusic != null) {
      await _ensurePlayerContext();
      await _musicPlayer.setVolume(_duckedVolume);
      await _player.stop();
      await _player.play(BytesSource(_shortBeep!));
      await Future.delayed(const Duration(milliseconds: 200));
      await _musicPlayer.setVolume(_musicVolume);
    } else {
      await _player.stop();
      await _player.play(BytesSource(_shortBeep!));
    }
  }

  /// Play long beep with music ducking.
  Future<void> playLongBeep() async {
    _ensureGenerated();
    if (_currentMusic != null) {
      await _ensurePlayerContext();
      await _musicPlayer.setVolume(_duckedVolume);
      await _player.stop();
      await _player.play(BytesSource(_longBeep!));
      await Future.delayed(const Duration(milliseconds: 500));
      await _musicPlayer.setVolume(_musicVolume);
    } else {
      await _player.stop();
      await _player.play(BytesSource(_longBeep!));
    }
  }

  /// Play music in loop. Pass null to stop music.
  /// If the same track is already playing, does nothing (no restart).
  Future<void> playMusic(String? music) async {
    if (music == null) {
      await stopMusic();
      return;
    }
    if (_currentMusic == music) return;
    await _musicPlayer.stop();
    _currentMusic = music;
    await _musicPlayer.setVolume(_musicVolume);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.play(AssetSource('audio/$music'));
  }

  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  Future<void> resumeMusic() async {
    if (_currentMusic != null) {
      await _musicPlayer.resume();
    }
  }

  Future<void> stopMusic() async {
    _currentMusic = null;
    await _musicPlayer.stop();
  }

  /// Short preview of an asset (tone or music).
  Future<void> playPreview(String assetPath) async {
    await _previewPlayer.stop();
    await _previewPlayer.setReleaseMode(ReleaseMode.release);
    await _previewPlayer.play(AssetSource(assetPath));
    Future.delayed(const Duration(seconds: 3), () {
      _previewPlayer.stop();
    });
  }

  Uint8List _generateWav(double durationSec, double frequency) {
    const sampleRate = 44100;
    final numSamples = (sampleRate * durationSec).toInt();
    final dataSize = numSamples * 2;

    final bytes = ByteData(44 + dataSize);

    // RIFF header
    _writeStr(bytes, 0, 'RIFF');
    bytes.setUint32(4, 36 + dataSize, Endian.little);
    _writeStr(bytes, 8, 'WAVE');

    // fmt chunk
    _writeStr(bytes, 12, 'fmt ');
    bytes.setUint32(16, 16, Endian.little);
    bytes.setUint16(20, 1, Endian.little); // PCM
    bytes.setUint16(22, 1, Endian.little); // mono
    bytes.setUint32(24, sampleRate, Endian.little);
    bytes.setUint32(28, sampleRate * 2, Endian.little);
    bytes.setUint16(32, 2, Endian.little);
    bytes.setUint16(34, 16, Endian.little);

    // data chunk
    _writeStr(bytes, 36, 'data');
    bytes.setUint32(40, dataSize, Endian.little);

    // Sine wave with fade envelope to avoid clicks
    const fadeSec = 0.008;
    final fadeSamples = (sampleRate * fadeSec).toInt();

    for (var i = 0; i < numSamples; i++) {
      final t = i / sampleRate;
      var amp = 0.5;
      if (i < fadeSamples) {
        amp *= i / fadeSamples;
      } else if (i > numSamples - fadeSamples) {
        amp *= (numSamples - i) / fadeSamples;
      }
      final sample = (sin(2 * pi * frequency * t) * amp * 32767).toInt().clamp(
        -32768,
        32767,
      );
      bytes.setInt16(44 + i * 2, sample, Endian.little);
    }

    return bytes.buffer.asUint8List();
  }

  void _writeStr(ByteData data, int offset, String str) {
    for (var i = 0; i < str.length; i++) {
      data.setUint8(offset + i, str.codeUnitAt(i));
    }
  }

  void dispose() {
    _player.dispose();
    _musicPlayer.dispose();
    _previewPlayer.dispose();
  }
}
