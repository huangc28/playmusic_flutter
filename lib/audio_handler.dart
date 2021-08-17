import 'dart:typed_data';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import './buffer_audio_source.dart';

Future<AudioHandler> initAudioService() {
  return AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.playmusic.app.channel.audio',
      androidNotificationChannelName: 'YT audio background play',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class AudioPlayerHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  /// Note that our audio source coming from  BufferAudioSource.
  final _playlist = ConcatenatingAudioSource(children: []);

  AudioPlayerHandler() {
    _loadEmptyPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();

    // playbackState.add(playbackState.value.copyWith(
    //   controls: [MediaControl.play],
    //   processingState: AudioProcessingState.loading,
    // ));

    // @TODO We need to find a way to provide byte data to audio player.
    // _player
    //     .setUrl("https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3")
    //     .then((duration) {
    //   playbackState.value.copyWith(
    //     processingState: AudioProcessingState.ready,
    //   );
    // });
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

  LockCachingAudioSource _createLockCachingAudioSource(MediaItem mediaItem) {
    return LockCachingAudioSource(
      Uri.parse(mediaItem.extras!['url']),
    );
  }

  BufferAudioSource _createBufferAudioSource(MediaItem meidaItem) {
    final _byteBuilder = BytesBuilder();

    return BufferAudioSource(_byteBuilder.toBytes());
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      final index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }
}
