import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
// import "package:semo/components/episode_card.dart";
import "package:semo/components/spinner.dart";
import "package:semo/models/anime.dart";
import "package:semo/screens/anime_player_screen.dart";
import "package:semo/screens/base_screen.dart";
import "package:semo/services/anime_service.dart";
import "package:semo/utils/navigation_helper.dart";

class AnimeDetailsScreen extends BaseScreen {
  final Anime anime;

  const AnimeDetailsScreen({
    super.key,
    required this.anime,
  });

  @override
  BaseScreenState<AnimeDetailsScreen> createState() => _AnimeDetailsScreenState();
}

class _AnimeDetailsScreenState extends BaseScreenState<AnimeDetailsScreen> {
  final AnimeService _animeService = AnimeService();
  
  Anime? _detailedAnime;
  List<AnimeEpisode> _episodes = <AnimeEpisode>[];
  bool _isLoading = true;
  bool _isLoadingEpisodes = false;

  @override
  void initState() {
    super.initState();
    _loadAnimeDetails();
  }

  Future<void> _loadAnimeDetails() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Anime? details = await _animeService.getAnimeDetails(widget.anime.id);
      if (details != null) {
        setState(() {
          _detailedAnime = details;
        });
      }

      await _loadEpisodes();
    } catch (e) {
      logger.e("Failed to load anime details", error: e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadEpisodes() async {
    setState(() {
      _isLoadingEpisodes = true;
    });

    try {
      final List<AnimeEpisode> episodes = await _animeService.getAnimeEpisodes(widget.anime.id);
      setState(() {
        _episodes = episodes;
      });
    } catch (e) {
      logger.e("Failed to load anime episodes", error: e);
    }

    setState(() {
      _isLoadingEpisodes = false;
    });
  }

  void _playEpisode(AnimeEpisode episode) {
    NavigationHelper.navigate(
      context,
      AnimePlayerScreen(
        anime: _detailedAnime ?? widget.anime,
        episode: episode,
      ),
    );
  }

  @override
  String get screenName => "Anime Details";

  @override
  Widget buildContent(BuildContext context) {
    final Anime currentAnime = _detailedAnime ?? widget.anime;

    return Scaffold(
      body: _isLoading
          ? const Center(child: Spinner())
          : CustomScrollView(
              slivers: <Widget>[
                _buildSliverAppBar(currentAnime),
                SliverToBoxAdapter(
                  child: _buildAnimeInfo(currentAnime),
                ),
                if (_episodes.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildEpisodesSection(),
                  ),
              ],
            ),
    );
  }

  Widget _buildSliverAppBar(Anime anime) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          anime.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (anime.image != null)
              CachedNetworkImage(
                imageUrl: anime.image!,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  color: Colors.grey[800],
                ),
                errorWidget: (BuildContext context, String url, dynamic error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 64,
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimeInfo(Anime anime) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Basic info
          Row(
            children: <Widget>[
              if (anime.type != null)
                _buildInfoChip(anime.type!),
              if (anime.status != null)
                _buildInfoChip(anime.status!),
              if (anime.rating != null)
                _buildRatingChip(anime.rating!),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          if (anime.description != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Synopsis",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  anime.description!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          // Additional info
          _buildAdditionalInfo(anime),
          
          // Genres
          if (anime.genres.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 16),
                Text(
                  "Genres",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: anime.genres.map((String genre) => _buildGenreChip(genre)).toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildRatingChip(double rating) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.star,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String genre) {
    return Chip(
      label: Text(
        genre,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: Colors.grey[700],
    );
  }

  Widget _buildAdditionalInfo(Anime anime) {
    return Column(
      children: <Widget>[
        if (anime.totalEpisodes != null)
          _buildInfoRow("Episodes", anime.totalEpisodes.toString()),
        if (anime.studio != null)
          _buildInfoRow("Studio", anime.studio!),
        if (anime.releaseDate != null)
          _buildInfoRow("Release Date", anime.releaseDate!),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            "Episodes",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (_isLoadingEpisodes)
          const Center(child: Spinner())
        else if (_episodes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "No episodes available",
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _episodes.length,
            itemBuilder: (BuildContext context, int index) {
              final AnimeEpisode episode = _episodes[index];
              return _buildAnimeEpisodeCard(episode);
            },
          ),
      ],
    );
  }

  Widget _buildAnimeEpisodeCard(AnimeEpisode episode) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _playEpisode(episode),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              Container(
                width: 60,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    episode.episodeNumber.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      episode.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (episode.description != null)
                      Text(
                        episode.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (episode.airDate != null)
                      Text(
                        episode.airDate!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}