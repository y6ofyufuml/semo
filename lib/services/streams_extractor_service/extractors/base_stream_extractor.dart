import "package:build_x/models/media_stream.dart";
import "package:build_x/enums/media_type.dart";
import "package:build_x/models/stream_extractor_options.dart";

abstract class BaseStreamExtractor {
  List<MediaType> get acceptedMediaTypes;
  bool get needsExternalLink;
  Future<Map<String, Object?>?> getExternalLink(StreamExtractorOptions options);

  // New multi-stream API. For now, implementations should return at most one.
  Future<List<MediaStream>> getStreams(
    StreamExtractorOptions options, {
    String? externalLink,
    Map<String, String>? externalLinkHeaders,
  });

  // Common headers for HTTP requests
  Map<String, String> getCommonHeaders() {
    return {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
      'Accept-Encoding': 'gzip, deflate',
      'Connection': 'keep-alive',
      'Upgrade-Insecure-Requests': '1',
    };
  }
}
