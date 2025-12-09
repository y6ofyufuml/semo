import "package:build_x/enums/stream_type.dart";
import "package:build_x/models/stream_audio.dart";
import "package:build_x/models/stream_subtitles.dart";

class MediaStream {
  MediaStream({
    required this.type,
    required this.url,
    this.headers,
    this.quality = "Auto",
    this.subtitles,
    this.audios,
    this.hasDefaultAudio = true,
  });

  final StreamType type;
  final String url;
  final Map<String, String>? headers;
  final String quality;
  final List<StreamSubtitles>? subtitles;
  final List<StreamAudio>? audios;
  final bool hasDefaultAudio;
}
