# Playmusic

- Retrieve stream data from remote socket.
- Collect byte data from socket stream.
- Stream audio byte data using audiofileplayer.

## Add new music media item in audio service queue (Playlist)

``` dart
getIt<AudioHandler>()
  ..addQueueItems(
    [
      MediaItem(
        id: 'example mp3',
        title: 'example mp3',
        extras: {
          'url': exampleUrl,
        },
      ),
    ],
  );
```
