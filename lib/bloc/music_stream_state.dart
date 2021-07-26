part of 'music_stream_bloc.dart';

@immutable
abstract class MusicStreamState extends Equatable {
  MusicStreamState({
    this.channel,
    this.err,
    this.loading = LoadingStates.EMPTY,
  });

  /// Socket connection instance to the music streaming websocket server.
  final WebSocketChannel? channel;

  /// Error when socket connection failed.
  final Error? err;
  final LoadingStates loading;

  @override
  List<Object?> get props => [
        err,
        channel,
        loading,
      ];
}

class MusicStreamInitial extends MusicStreamState {
  MusicStreamInitial()
      : super(
          channel: null,
          err: null,
          loading: LoadingStates.EMPTY,
        );
}

class ConnectingSocket extends MusicStreamState {
  ConnectingSocket()
      : super(
          loading: LoadingStates.LOADING,
        );
}

class StreamSocketConnected extends MusicStreamState {
  StreamSocketConnected({
    required WebSocketChannel channel,
  }) : super(
          channel: channel,
          loading: LoadingStates.DONE,
        );
}

class DisconnectStreamSocket extends MusicStreamState {
  DisconnectStreamSocket() : super(channel: null);
}

class StreamSocketConnectFailed extends MusicStreamState {
  StreamSocketConnectFailed({
    required Error err,
  }) : super(
          err: err,
          loading: LoadingStates.ERROR,
        );
}
