import 'dart:math';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioService _instance = AudioService._();
  static AudioService get instance => _instance;
  AudioService._();

  final _player = AudioPlayer();
  Uint8List? _shortBeep;
  Uint8List? _longBeep;

  void _ensureGenerated() {
    _shortBeep ??= _generateWav(0.12, 880);
    _longBeep ??= _generateWav(0.45, 880);
  }

  Future<void> playShortBeep() async {
    _ensureGenerated();
    await _player.stop();
    await _player.play(BytesSource(_shortBeep!));
  }

  Future<void> playLongBeep() async {
    _ensureGenerated();
    await _player.stop();
    await _player.play(BytesSource(_longBeep!));
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
      final sample =
          (sin(2 * pi * frequency * t) * amp * 32767).toInt().clamp(-32768, 32767);
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
  }
}
