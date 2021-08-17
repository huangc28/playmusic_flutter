part of 'music_stream_bloc.dart';

@immutable
abstract class MusicStreamState extends Equatable {
  MusicStreamState({
    this.channel,
    this.err,
    this.loading = LoadingStatus.initial,
  });

  /// Socket connection instance to the music streaming websocket server.
  final WebSocketChannel? channel;

  /// Error when socket connection failed.
  final Error? err;
  final LoadingStatus loading;

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
          loading: LoadingStatus.initial,
        );
}

class ConnectingSocket extends MusicStreamState {
  ConnectingSocket()
      : super(
          loading: LoadingStatus.loading,
        );
}

class StreamSocketConnected extends MusicStreamState {
  StreamSocketConnected({
    required WebSocketChannel channel,
  }) : super(
          channel: channel,
          loading: LoadingStatus.done,
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
          loading: LoadingStatus.error,
        );
}
