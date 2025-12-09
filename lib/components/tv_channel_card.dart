import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:build_x/models/tv_channel.dart";

class TvChannelCard extends StatelessWidget {
  final TvChannel channel;
  final VoidCallback? onTap;

  const TvChannelCard({
    super.key,
    required this.channel,
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
              _buildChannelLogo(),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChannelInfo(context),
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

  Widget _buildChannelLogo() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: channel.logo != null && channel.logo!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: channel.logo!,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.tv,
                    color: Colors.white54,
                    size: 30,
                  ),
                ),
                errorWidget: (BuildContext context, String url, dynamic error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.tv,
                    color: Colors.white54,
                    size: 30,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.tv,
                  color: Colors.white54,
                  size: 30,
                ),
              ),
      ),
    );
  }

  Widget _buildChannelInfo(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          channel.name,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        if (channel.group != null && channel.group!.isNotEmpty)
          Text(
            channel.group!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (channel.country != null && channel.country!.isNotEmpty)
          Text(
            channel.country!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.white54,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class TvChannelGridCard extends StatelessWidget {
  final TvChannel channel;
  final VoidCallback? onTap;

  const TvChannelGridCard({
    super.key,
    required this.channel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: _buildChannelLogo(),
            ),
            Expanded(
              flex: 2,
              child: _buildChannelInfo(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelLogo() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[800],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: channel.logo != null && channel.logo!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: channel.logo!,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.tv,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
                errorWidget: (BuildContext context, String url, dynamic error) => Container(
                  color: Colors.grey[800],
                  child: const Icon(
                    Icons.tv,
                    color: Colors.white54,
                    size: 40,
                  ),
                ),
              )
            : Container(
                color: Colors.grey[800],
                child: const Icon(
                  Icons.tv,
                  color: Colors.white54,
                  size: 40,
                ),
              ),
      ),
    );
  }

  Widget _buildChannelInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            channel.name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (channel.country != null && channel.country!.isNotEmpty)
            Text(
              channel.country!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}