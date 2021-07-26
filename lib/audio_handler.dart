import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import './buffer_audio_source.dart';

Future<AudioHandler> initAudioService() {
  return AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.playmusic.app.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
    ),
  );
}

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  /// Note that our audio source coming from  BufferAudioSource.
  final _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayerHandler() {
    _loadEmptyPlaylist();

    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play],
      processingState: AudioProcessingState.loading,
    ));

    // @TODO We need to find a way to provide byte data to audio player.
    _player
        .setUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
        .then((duration) {
      playbackState.value.copyWith(
        processingState: AudioProcessingState.ready,
      );
    });
  }

  _loadEmptyPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print('Error $e');
    }
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // Manage Just Audio
    final audioSource = mediaItems.map(_createUriAudioSource);
    _playlist.addAll(audioSource.toList());

    print('add queue items ${mediaItems[0]}');

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  UriAudioSource _createUriAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url']),
      tag: mediaItem,
    );
  }

  BufferAudioSource _createBufferAudioSource(MediaItem meidaItem) {
    final _byteBuilder = BytesBuilder();

    return BufferAudioSource(_byteBuilder.toBytes());
  }

  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      playing: true,
      controls: [MediaControl.pause],
    ));

    await _player.play();
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      playing: false,
      controls: [MediaControl.play],
    ));

    await _player.pause();
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }
}
