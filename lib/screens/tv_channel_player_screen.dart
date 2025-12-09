import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:media_kit/media_kit.dart";
import "package:media_kit_video/media_kit_video.dart";
import "package:semo/models/tv_channel.dart";
import "package:semo/screens/base_screen.dart";
import "package:wakelock_plus/wakelock_plus.dart";

class TvChannelPlayerScreen extends BaseScreen {
  final TvChannel channel;

  const TvChannelPlayerScreen({
    super.key,
    required this.channel,
  });

  @override
  BaseScreenState<TvChannelPlayerScreen> createState() => _TvChannelPlayerScreenState();
}

class _TvChannelPlayerScreenState extends BaseScreenState<TvChannelPlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isControlsVisible = true;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

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
      logger.e("TV Channel player error: $error");
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

    _loadChannel();
  }

  Future<void> _loadChannel() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      await _player.open(Media(widget.channel.url));
      
      logger.i("Playing TV channel: ${widget.channel.name}");
    } catch (e, s) {
      logger.e("Failed to load TV channel", error: e, stackTrace: s);
      setState(() {
        _hasError = true;
        _errorMessage = "Failed to load channel: ${e.toString()}";
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
  String get screenName => "TV Channel Player";

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
                      onPressed: _loadChannel,
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
                  widget.channel.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.channel.group != null)
                  Text(
                    widget.channel.group!,
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
              Icons.refresh,
              color: Colors.white,
              size: 32,
            ),
            onPressed: _loadChannel,
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
          StreamBuilder<double>(
            stream: _player.stream.volume,
            builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
              final double volume = snapshot.data ?? 1.0;
              return IconButton(
                icon: Icon(
                  volume > 0 ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white,
                  size: 32,
                ),
                onPressed: () {
                  if (volume > 0) {
                    _player.setVolume(0);
                  } else {
                    _player.setVolume(1.0);
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void handleDispose() {
    _exitFullScreen();
    WakelockPlus.disable();
    _player.dispose();
  }
}