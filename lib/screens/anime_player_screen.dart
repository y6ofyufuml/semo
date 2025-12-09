import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:media_kit/media_kit.dart";
import "package:media_kit_video/media_kit_video.dart";
import "package:semo/models/anime.dart";
import "package:semo/models/media_stream.dart";
import "package:semo/screens/base_screen.dart";
import "package:semo/services/anime_service.dart";
import "package:wakelock_plus/wakelock_plus.dart";

class AnimePlayerScreen extends BaseScreen {
  final Anime anime;
  final AnimeEpisode episode;

  const AnimePlayerScreen({
    super.key,
    required this.anime,
    required this.episode,
  });

  @override
  BaseScreenState<AnimePlayerScreen> createState() => _AnimePlayerScreenState();
}

class _AnimePlayerScreenState extends BaseScreenState<AnimePlayerScreen> {
  final AnimeService _animeService = AnimeService();
  late final Player _player;
  late final VideoController _videoController;
  
  bool _isControlsVisible = true;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  List<MediaStream> _streams = <MediaStream>[];

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _setFullScreen();
    WakelockPlus.enable();
  }

  void _initializePlayer() {
    _player = Player();
    _videoController = VideoController(_player);
    
    _player.stream.error.listen((String error) {
      logger.e("Anime player error: $error");
      setState(() {
        _hasError = true;
        _errorMessage = error;
        _isLoading = false;
      });
    });

    _player.stream.buffering.listen((bool buffering) {
      setState(() {
        _isLoading = buffering;
      });
    });

    _loadEpisode();
  }

  Future<void> _loadEpisode() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      final List<MediaStream> streams = await _animeService.getAnimeStreams(
        widget.anime.id,
        widget.episode.episodeNumber,
      );

      if (streams.isEmpty) {
        setState(() {
          _hasError = true;
          _errorMessage = "No streams available for this episode";
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _streams = streams;
      });

      // Play the first available stream
      final MediaStream stream = streams.first;
      await _player.open(Media(stream.url));
      
      logger.i("Playing anime episode: ${widget.anime.name} - Episode ${widget.episode.episodeNumber}");
    } catch (e, s) {
      logger.e("Failed to load anime episode", error: e, stackTrace: s);
      setState(() {
        _hasError = true;
        _errorMessage = "Failed to load episode: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  void _exitFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ]);
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  @override
  String get screenName => "Anime Player";

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        child: Stack(
          children: <Widget>[
            // Video player
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Video(
                  controller: _videoController,
                  controls: NoVideoControls,
                ),
              ),
            ),
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            
            // Error message
            if (_hasError)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage ?? "Unknown error occurred",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadEpisode,
                      child: const Text("Retry"),
                    ),
                  ],
                ),
              ),
            
            // Controls overlay
            if (_isControlsVisible)
              _buildControlsOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            // Top controls
            _buildTopControls(),
            const Spacer(),
            // Bottom controls
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.anime.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Episode ${widget.episode.episodeNumber}: ${widget.episode.title}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (_streams.length > 1)
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 24,
              ),
              onPressed: _showQualitySelector,
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.replay_10,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              final Duration currentPosition = _player.state.position;
              final Duration newPosition = currentPosition - const Duration(seconds: 10);
              _player.seek(newPosition > Duration.zero ? newPosition : Duration.zero);
            },
          ),
          const SizedBox(width: 32),
          StreamBuilder<bool>(
            stream: _player.stream.playing,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              final bool isPlaying = snapshot.data ?? false;
              return IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: () {
                  if (isPlaying) {
                    _player.pause();
                  } else {
                    _player.play();
                  }
                },
              );
            },
          ),
          const SizedBox(width: 32),
          IconButton(
            icon: const Icon(
              Icons.forward_10,
              color: Colors.white,
              size: 32,
            ),
            onPressed: () {
              final Duration currentPosition = _player.state.position;
              final Duration duration = _player.state.duration;
              final Duration newPosition = currentPosition + const Duration(seconds: 10);
              _player.seek(newPosition < duration ? newPosition : duration);
            },
          ),
        ],
      ),
    );
  }

  void _showQualitySelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "Select Quality",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ..._streams.map((MediaStream stream) {
                return ListTile(
                  title: Text(
                    stream.quality,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () async {
                    Navigator.of(context).pop();
                    await _player.open(Media(stream.url));
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  void handleDispose() {
    _exitFullScreen();
    WakelockPlus.disable();
    _player.dispose();
  }
}