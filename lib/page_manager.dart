import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';

import './service_locator.dart';

class PageManager {
  // Listeners: Updates going to the UI.
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);

  // Events: Calls coming from the UI.
  void init() async {
    // We added example video hash here.
    // Load initial play list
    await _loadPlaylist();

    _listenToChangesInPlaylist();
  }

  // TODO: The playlist should be retrieved from remote API instead.
  Future<void> _loadPlaylist() async {
    // Retrieve audio bytes here. The audio bytes is a growable list
    // and pass down to the audio_handler.

    getIt<AudioHandler>()
      ..addQueueItems(
        [
          // MediaItem(
          //   id: 'DEcxTQHH3Rc',
          //   title: 'eminem 8 miles',
          //   extras: {
          //     'url':
          //         'https://www.youtube.com/watch?v=DEcxTQHH3Rc&list=PLBFgR0azYntybBkSIT1qS4RXp-WTvxPCw&index=11&ab_channel=RapMusicHD',
          //   },
          // ),
          MediaItem(
            id: 'example mp3',
            title: 'example mp3',
            extras: {
              'url':
                  'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
            },
          ),
        ],
      );

    play();
  }

  void _listenToChangesInPlaylist() {
    getIt<AudioHandler>().queue.listen((playlist) {
      if (playlist.isEmpty) return;
      final newList = playlist.map((item) => item.title).toList();
      playlistNotifier.value = newList;
    });
  }

  void play() {
    getIt<AudioHandler>().play();
  }

  void dispose() {
    getIt<AudioHandler>().customAction('dispose');
  }
}
