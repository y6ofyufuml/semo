import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:build_x/bloc/app_bloc.dart";
import "package:build_x/bloc/app_event.dart";
import "package:build_x/bloc/app_state.dart";
import "package:build_x/components/media_card.dart";
import "package:build_x/components/snack_bar.dart";
import "package:build_x/components/vertical_media_list.dart";
import "package:build_x/models/movie.dart";
import "package:build_x/models/tv_show.dart";
import "package:build_x/screens/base_screen.dart";
import "package:build_x/screens/movie_screen.dart";
import "package:build_x/screens/tv_show_screen.dart";
import "package:build_x/enums/media_type.dart";

class FavoritesScreen extends BaseScreen {
  const FavoritesScreen({
    super.key,
    required this.mediaType,
  });

  final MediaType mediaType;

  @override
  BaseScreenState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends BaseScreenState<FavoritesScreen> {
  //ignore: avoid_annotating_with_dynamic
  Widget _buildMediaCard(dynamic media, int index) {
    VoidCallback onTap;

    if (widget.mediaType == MediaType.movies) {
      onTap = () {
        final Movie m = media as Movie;
        navigate(MovieScreen(m));
      };
    } else {
      onTap = () {
        final TvShow tv = media as TvShow;
        navigate(TvShowScreen(tv));
      };
    }

    String posterPath = media.posterPath ?? "";
    double voteAverage = media.voteAverage ?? 0;

    return MediaCard(
      posterPath: posterPath,
      voteAverage: voteAverage,
      onTap: onTap,
      showRemoveOption: true,
      onRemove: () {
        // Delay the removal to escape dispose error
        Timer(const Duration(milliseconds: 500), () {
          final Map<String, Object?> params = <String, Object?>{
            "media_type": widget.mediaType.toJsonField(),
            "tmdb_id": media.id,
          };
          unawaited(logEvent("favorite_remove", parameters: params));
          context.read<AppBloc>().add(
                RemoveFavorite(media, widget.mediaType),
              );
        });
      },
    );
  }

  @override
  String get screenName => "Favorites";

  @override
  Widget buildContent(BuildContext context) => Scaffold(
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 18,
            ),
            child: BlocConsumer<AppBloc, AppState>(
              listener: (BuildContext context, AppState state) {
                if (state.error != null) {
                  showSnackBar(context, state.error!);
                  context.read<AppBloc>().add(ClearError());
                }
              },
              builder: (BuildContext context, AppState state) {
                List<dynamic> favorites = <dynamic>[];

                if (widget.mediaType == MediaType.movies) {
                  favorites = state.favoriteMovies ?? <Movie>[];
                } else if (widget.mediaType == MediaType.tvShows) {
                  favorites = state.favoriteTvShows ?? <TvShow>[];
                }

                return VerticalMediaList<dynamic>(
                  isLoading: state.isLoadingFavorites,
                  items: favorites,
                  //ignore: avoid_annotating_with_dynamic
                  itemBuilder: (BuildContext context, dynamic media, int index) => _buildMediaCard(media, index),
                  emptyStateMessage: "You don't have any favorite ${widget.mediaType.toString()}",
                  errorMessage: "Failed to load favorite ${widget.mediaType.toString()}",
                  shrinkWrap: false,
                  physics: const AlwaysScrollableScrollPhysics(),
                );
              },
            ),
          ),
        ),
      );
}
