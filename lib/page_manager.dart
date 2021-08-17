import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';

import 'notifiers/progress_notifier.dart';
import 'notifiers/play_button_notifier.dart';

import './service_locator.dart';

const exampleUrl =
    "https://r1---sn-ipoxu-un5ez.googlevideo.com/videoplayback?expire=1628627333&ei=JY0SYY2cBdWH1d8P5NSVGA&ip=220.136.43.62&id=o-ANdNrl7rDm-Dzm7tAua7EdJ3TpUj9P78KWx8F6NBwBoW&itag=140&source=youtube&requiressl=yes&mh=XK&mm=31%2C26&mn=sn-ipoxu-un5ez%2Csn-ogul7n7z&ms=au%2Conr&mv=m&mvi=1&pl=20&initcwndbps=552500&vprv=1&mime=audio%2Fmp4&ns=gONauxfgQFKrtl5f0RfWSIMG&gir=yes&clen=4550815&dur=281.147&lmt=1626401778889869&mt=1628605491&fvip=1&keepalive=yes&fexp=24001373%2C24007246&beids=9466588&c=WEB&txp=5432434&n=52WOaqd4Rx4qFvKENU3&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cns%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRQIgFJi4Mi7VxHIbKfIK03a0_MXulYBsoxNQ4zqlTEJVProCIQDBEp8vGdtD1nS1yu60LQ_LUTsShFH7Tvqx7WLR2CVhCA%3D%3D&sig=AOq0QJ8wRQIgPXi_nxwHF4GhyTlSg6QrAeqOPP7KqB0Bd1_dF_mA6nICIQD_uYRj-IzcU1iDojg2ivRswKEmzXgKcqSYvDZDbKP9uA==";

class PageManager {
  // Listeners: Updates going to the UI.
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final playButtonNotifier = PlayButtonNotifier();

  final _audioHandler = getIt<AudioHandler>();
  // Events: Calls coming from the UI.
  void init() async {
    // We added example video hash here.
    // Load initial play list
    await _loadPlaylist();

    _listenToChangesInPlaylist();

    _listenToPlaybackState();

    _listenToCurrentPosition();

    _listenToBufferedPosition();

    _listenToTotalDuration();
  }

  // TODO: The playlist should be retrieved from remote API instead.
  Future<void> _loadPlaylist() async {
    // Retrieve audio bytes here. The audio bytes is a growable list
    // and pass down to the audio_handler.
  }

  void _listenToChangesInPlaylist() {
    getIt<AudioHandler>().queue.listen(
      (playlist) {
        if (playlist.isEmpty) return;
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      },
    );
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading ||
          processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void addQueueItems(List<MediaItem> items) {
    getIt<AudioHandler>()..addQueueItems(items);
  }

  void play() => getIt<AudioHandler>().play();

  void pause() => getIt<AudioHandler>().pause();

  void seek(Duration position) => _audioHandler.seek(position);

  void dispose() => getIt<AudioHandler>().customAction('dispose');
}
