import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';

import 'package:playmusic_flutter/constants.dart';

import './buffer_audio_source.dart';
import './service_locator.dart' show getIt;
import './audio_player_task.dart';
import './bloc/music_stream_bloc.dart';
import './audio_handler.dart';
import './playlist.dart';
import './page_manager.dart';

class Landing extends StatefulWidget {
  Landing({Key? key}) : super(key: key);

  @override
  _LandingState createState() => _LandingState();
}

void handleConnectSocket(context) {
  BlocProvider.of<MusicStreamBloc>(context).add(StreamMuisc());
}

class _LandingState extends State<Landing> {
  final AudioPlayer _player = AudioPlayer();

  BytesBuilder _bytesBuilder = BytesBuilder();

  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();

    _init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();

    super.dispose();
  }

  _init() async {
    try {
      // Listen to errors during playback.
      _player.playbackEventStream.listen(
        (event) {},
        onError: (Object e, StackTrace stackTrace) {
          print('A stream error occurred: $e');
        },
        onDone: () {
          // Clear buffer once playing is done.
          print('Done buffering');
        },
      );
    } on Error catch (err) {
      print('err $err');
    }
  }

  handleDoneBuffering() async {
    try {
      Uint8List bytes = _bytesBuilder.toBytes();

      await _player.setAudioSource(
        BufferAudioSource(bytes),
      );

      await _player.play();
    } on Error catch (err) {
      print('failed to handle $err');
    }
  }

  handleStart() {
    print('handle start 1');

    print('handle start 2');
  }

  handleStop() async {
    // await AudioService.stop();
    print('stop');
  }

  // This is the entry point to our background isolates for audio processing.
  _backgroundTaskEntrypoint() async {
    // AudioServiceBackground.run(() => AudioPlayerTask());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<MusicStreamBloc, MusicStreamState>(
            listener: (context, state) {
          if (state.loading == LoadingStates.ERROR) {
            print('failed to connect to socket ${state.err}');
          }

          if (state.loading == LoadingStates.DONE) {
            // start listen to byte stream.
            state.channel?.stream.listen(
              (dynamic data) {
                print('byte  ${data.runtimeType}');
                // We need to stream those byte to a byte builder. We are receiving the following
                // formats from server:
                //   _Uint8ArrayView
                //   Uint8List
                // We use BytesBuilder to collect all bytes array into one Uint8List and play audio bytes
                // using audio player .

                _bytesBuilder.add(data);

                setState(() {});
              },
              onDone: handleDoneBuffering,
            );
          }
        }, builder: (context, state) {
          return Center(
            child: StreamBuilder<PlaybackState>(
              stream: getIt<AudioHandler>().playbackState,
              builder: (context, snapshot) {
                return Column(
                  children: [
                    ElevatedButton(
                      child: Text('Start'),
                      onPressed: handleStart,
                    ),
                    ElevatedButton(
                      child: Text('Stop'),
                      onPressed: handleStop,
                    ),

                    Playlist(),

                    // streaming button
                    TextButton(
                      onPressed: () => handleConnectSocket(context),
                      child: Text('start streaming'),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
