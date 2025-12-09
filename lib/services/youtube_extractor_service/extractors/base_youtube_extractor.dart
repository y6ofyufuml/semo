import "package:build_x/models/media_stream.dart";

abstract class BaseYoutubeExtractor {
  Future<List<MediaStream>> extractStreams(String youtubeUrl);
}
