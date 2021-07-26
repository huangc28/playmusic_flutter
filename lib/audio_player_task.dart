import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';

class AudioPlayerTask extends BackgroundAudioTask {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    print('trigger bg start');
  }

  @override
  Future<void> onStop() async {
    print('trigger bg stop');

    super.onStop();
  }
}
