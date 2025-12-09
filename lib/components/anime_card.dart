import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:semo/models/anime.dart";

class AnimeCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;

  const AnimeCard({
    super.key,
    required this.anime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: _buildAnimePoster(),
            ),
            Expanded(
              flex: 2,
              child: _buildAnimeInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimePoster() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        color: Colors.grey[800],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: anime.image != null && anime.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: anime.image!,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (BuildContext context, String url, dynamic error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.movie,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
      ),
    );
  }

  Widget _buildAnimeInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            anime.name,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (anime.type != null)
            Text(
              anime.type!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          if (anime.rating != null)
            Row(
              children: <Widget>[
                const Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  anime.rating!.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class AnimeListCard extends StatelessWidget {
  final Anime anime;
  final VoidCallback? onTap;

  const AnimeListCard({
    super.key,
    required this.anime,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: <Widget>[
              _buildAnimePoster(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimeInfo(context),
              ),
              const Icon(
                Icons.play_circle_outline,
                color: Colors.white70,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimePoster() {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: anime.image != null && anime.image!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: anime.image!,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 30,
                  ),
                ),
                errorWidget: (BuildContext context, String url, dynamic error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.movie,
                    color: Colors.white54,
                    size: 30,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.movie,
                  color: Colors.white54,
                  size: 30,
                ),
              ),
      ),
    );
  }

  Widget _buildAnimeInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          anime.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (anime.type != null)
          Text(
            anime.type!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (anime.totalEpisodes != null)
          Text(
            "${anime.totalEpisodes} episodes",
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (anime.rating != null)
          Row(
            children: <Widget>[
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                anime.rating!.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white54,
                ),
              ),
            ],
          ),
      ],
    );
  }
}