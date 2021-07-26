import 'package:just_audio/just_audio.dart';
import 'dart:typed_data';

// We implement a customed audio source in order to
// let just_audio to play on audio bytes properly.
// For detail solution please refer to this github issue:
//   - https://github.com/ryanheise/just_audio/issues/187
//   - https://stackoverflow.com/questions/67078045/flutter-just-audio-package-how-play-audio-from-bytes
class BufferAudioSource extends StreamAudioSource {
  Uint8List _buffer;

  BufferAudioSource(this._buffer) : super();

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) {
    start = start ?? 0;
    end = end ?? _buffer.length;

    return Future.value(
      StreamAudioResponse(
        sourceLength: _buffer.length,
        contentLength: end - start,
        offset: start,
        contentType: 'audio/m4a',
        stream:
            Stream.value(List<int>.from(_buffer.skip(start).take(end - start))),
      ),
    );
  }
}
