import "dart:async";
import "dart:convert";
import "dart:io";

import "package:dio/dio.dart";
import "package:logger/logger.dart";
import "package:build_x/enums/media_type.dart";
import "package:build_x/enums/stream_type.dart";
import "package:build_x/models/media_stream.dart";
import "package:build_x/models/stream_extractor_options.dart";
import "package:build_x/models/stream_subtitles.dart";
import "package:build_x/models/stream_audio.dart";
import "package:build_x/services/streams_extractor_service/extractors/base_stream_extractor.dart";
import "package:build_x/services/streams_extractor_service/extractors/utils/common_headers.dart";

class SuperEmbedExtractor extends BaseStreamExtractor {
  final Logger _logger = Logger();
  final Dio _dio = Dio();

  @override
  List<MediaType> get acceptedMediaTypes => <MediaType>[MediaType.movies, MediaType.tvShows];

  @override
  bool get needsExternalLink => false;

  @override
  Future<Map<String, Object?>?> getExternalLink(StreamExtractorOptions options) async {
    return null;
  }

  @override
  Future<List<MediaStream>> getStreams(
    StreamExtractorOptions options, {
    String? externalLink,
    Map<String, String>? externalLinkHeaders,
  }) async {
    try {
      final List<MediaStream> streams = <MediaStream>[];
      
      // Try VIP player first
      final List<MediaStream> vipStreams = await _getVipStreams(options);
      if (vipStreams.isNotEmpty) {
        streams.addAll(vipStreams);
      }
      
      // Fallback to regular player
      if (streams.isEmpty) {
        final List<MediaStream> regularStreams = await _getRegularStreams(options);
        streams.addAll(regularStreams);
      }

      return streams;
    } catch (e, s) {
      _logger.e("SuperEmbed extraction failed", error: e, stackTrace: s);
      return <MediaStream>[];
    }
  }

  Future<List<MediaStream>> _getVipStreams(StreamExtractorOptions options) async {
    try {
      final String baseUrl = "https://multiembed.mov/directstream.php";
      final String videoId = options.tmdbId?.toString() ?? options.imdbId ?? "";
      
      if (videoId.isEmpty) {
        _logger.w("No TMDB or IMDB ID provided for SuperEmbed VIP");
        return <MediaStream>[];
      }

      // Check if VIP is available first
      final String checkUrl = _buildVipUrl(videoId, options, check: true);
      final Response<String> checkResponse = await _dio.get<String>(
        checkUrl,
        options: Options(
          headers: getCommonHeaders(),
          validateStatus: (int? status) => status != null && status < 500,
        ),
      );

      if (checkResponse.data?.trim() != "1") {
        _logger.i("VIP player not available for $videoId");
        return <MediaStream>[];
      }

      // Get VIP player
      final String playerUrl = _buildVipUrl(videoId, options);
      final MediaStream stream = MediaStream(
        type: StreamType.hls,
        url: playerUrl,
        quality: "VIP Multi-Quality",
        headers: getCommonHeaders(),
        subtitles: <StreamSubtitles>[],
        audios: <StreamAudio>[],
        hasDefaultAudio: true,
      );

      _logger.i("SuperEmbed VIP stream found for $videoId");
      return <MediaStream>[stream];
    } catch (e, s) {
      _logger.e("SuperEmbed VIP extraction failed", error: e, stackTrace: s);
      return <MediaStream>[];
    }
  }

  Future<List<MediaStream>> _getRegularStreams(StreamExtractorOptions options) async {
    try {
      final String baseUrl = "https://multiembed.mov/";
      final String videoId = options.tmdbId?.toString() ?? options.imdbId ?? "";
      
      if (videoId.isEmpty) {
        _logger.w("No TMDB or IMDB ID provided for SuperEmbed");
        return <MediaStream>[];
      }

      final String playerUrl = _buildRegularUrl(videoId, options);
      final MediaStream stream = MediaStream(
        type: StreamType.hls,
        url: playerUrl,
        quality: "Standard",
        headers: getCommonHeaders(),
        subtitles: <StreamSubtitles>[],
        audios: <StreamAudio>[],
        hasDefaultAudio: true,
      );

      _logger.i("SuperEmbed regular stream found for $videoId");
      return <MediaStream>[stream];
    } catch (e, s) {
      _logger.e("SuperEmbed regular extraction failed", error: e, stackTrace: s);
      return <MediaStream>[];
    }
  }

  String _buildVipUrl(String videoId, StreamExtractorOptions options, {bool check = false}) {
    final StringBuffer url = StringBuffer("https://multiembed.mov/directstream.php?video_id=$videoId");
    
    // Add TMDB flag if using TMDB ID
    if (options.tmdbId != null) {
      url.write("&tmdb=1");
    }
    
    // Add season and episode for TV shows
    if (options.season != null && options.episode != null) {
      url.write("&s=${options.season}&e=${options.episode}");
    }
    
    // Add check parameter if needed
    if (check) {
      url.write("&check=1");
    }
    
    return url.toString();
  }

  String _buildRegularUrl(String videoId, StreamExtractorOptions options) {
    final StringBuffer url = StringBuffer("https://multiembed.mov/?video_id=$videoId");
    
    // Add TMDB flag if using TMDB ID
    if (options.tmdbId != null) {
      url.write("&tmdb=1");
    }
    
    // Add season and episode for TV shows
    if (options.season != null && options.episode != null) {
      url.write("&s=${options.season}&e=${options.episode}");
    }
    
    return url.toString();
  }
}