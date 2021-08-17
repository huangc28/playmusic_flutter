import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'service_locator.dart' show getIt;
import 'page_manager.dart';
import 'notifiers/play_button_notifier.dart';

// This widget contains the following buttons:
//   - Repeat button
//   - Previous button
//   - Play button
//   - next song button
//   - shuffle button
class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          PlayButton(
            onPlay: () => getIt<PageManager>().play(),
            onPause: () => getIt<PageManager>().pause(),
          ),
        ],
      ),
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    Key? key,
    required this.onPlay,
    required this.onPause,
  }) : super(key: key);

  final VoidCallback onPlay;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.paused:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: onPlay,
            );
          case ButtonState.loading:
            return Container(
              margin: EdgeInsets.all(8.0),
              width: 32.0,
              height: 32.0,
              child: CircularProgressIndicator(),
            );
          case ButtonState.playing:
            return IconButton(
              icon: Icon(Icons.pause),
              iconSize: 32.0,
              onPressed: onPause,
            );

          default:
            return IconButton(
              icon: Icon(Icons.play_arrow),
              iconSize: 32.0,
              onPressed: onPlay,
            );
        }
      },
    );
  }
}
