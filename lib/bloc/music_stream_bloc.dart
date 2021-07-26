import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:playmusic_flutter/constants.dart';

part 'music_stream_event.dart';
part 'music_stream_state.dart';

// TODOs:
//   - We need to persist connection channel until the file download is completed.
//   - The widget can use persisted stream to listen to stream of audio data.
class MusicStreamBloc extends Bloc<MusicStreamEvent, MusicStreamState> {
  MusicStreamBloc() : super(MusicStreamInitial());

  @override
  Stream<MusicStreamState> mapEventToState(
    MusicStreamEvent event,
  ) async* {
    if (event is StreamMuisc) {
      yield* _mapStreamMusicToState();
    }

    if (event is DisconnectStreamSocket) {
      yield* _mapDisconnectStreamSocketToState();
    }
  }

  Stream<MusicStreamState> _mapStreamMusicToState() async* {
    try {
      yield ConnectingSocket();
      // Dial websocket server.
      final channel = WebSocketChannel.connect(
          Uri.parse('ws://10.0.2.2:8080/ws/music-stream'));

      yield StreamSocketConnected(channel: channel);
    } on Error catch (err) {
      yield StreamSocketConnectFailed(err: err);
    }
  }

  Stream<MusicStreamState> _mapDisconnectStreamSocketToState() async* {
    final conn = state.channel;

    if (conn != null) {
      conn.sink.close();
    }

    yield DisconnectStreamSocket();
  }
}
