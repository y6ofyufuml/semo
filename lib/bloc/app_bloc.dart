import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";
import "package:build_x/bloc/app_event.dart";
import "package:build_x/bloc/app_state.dart";
import "package:build_x/bloc/handlers/cache_handler.dart";
import "package:build_x/bloc/handlers/favorites_handler.dart";
import "package:build_x/bloc/handlers/general_handler.dart";
import "package:build_x/bloc/handlers/genres_handler.dart";
import "package:build_x/bloc/handlers/movie_handler.dart";
import "package:build_x/bloc/handlers/movies_handler.dart";
import "package:build_x/bloc/handlers/person_handler.dart";
import "package:build_x/bloc/handlers/recent_searches_handler.dart";
import "package:build_x/bloc/handlers/recently_watched_handler.dart";
import "package:build_x/bloc/handlers/stream_handler.dart";
import "package:build_x/bloc/handlers/trailer_handler.dart";
import "package:build_x/bloc/handlers/streaming_platforms_handler.dart";
import "package:build_x/bloc/handlers/tv_show_handler.dart";
import "package:build_x/bloc/handlers/tv_shows_handler.dart";
import "package:build_x/services/auth_service.dart";

class AppBloc extends Bloc<AppEvent, AppState>
    with GeneralHandler, CacheHandler, MoviesHandler, TvShowsHandler, StreamingPlatformsHandler, GenresHandler, RecentlyWatchedHandler, FavoritesHandler, MovieHandler, TvShowHandler, PersonHandler, RecentSearchesHandler, StreamHandler, TrailerHandler {
  AppBloc() : super(const AppState()) {
    // General
    on<LoadInitialData>(onLoadInitialData);
    on<AddError>(onAddError);
    on<ClearError>(onClearError);

    // Cache
    on<InitCacheTimer>(onInitCacheTimer);
    on<InvalidateCache>(onInvalidateCache);

    // Movies
    on<LoadMovies>(onLoadMovies);
    on<RefreshMovies>(onRefreshMovies);
    on<AddIncompleteMovies>(onAddIncompleteMovies);

    // TV Shows
    on<LoadTvShows>(onLoadTvShows);
    on<RefreshTvShows>(onRefreshTvShows);
    on<AddIncompleteTvShows>(onAddIncompleteTvShows);

    // Streaming Platforms
    on<LoadStreamingPlatformsMedia>(onLoadStreamingPlatformsMedia);
    on<RefreshStreamingPlatformsMedia>(onRefreshStreamingPlatformsMedia);

    // Genres
    on<LoadGenres>(onLoadGenres);
    on<RefreshGenres>(onRefreshGenres);

    // Recently Watched
    on<LoadRecentlyWatched>(onLoadRecentlyWatched);
    on<UpdateMovieProgress>(onUpdateMovieProgress);
    on<UpdateEpisodeProgress>(onUpdateEpisodeProgress);
    on<DeleteMovieProgress>(onDeleteMovieProgress);
    on<DeleteEpisodeProgress>(onDeleteEpisodeProgress);
    on<DeleteTvShowProgress>(onDeleteTvShowProgress);
    on<HideTvShowProgress>(onHideTvShowProgress);
    on<ClearRecentlyWatched>(onClearRecentlyWatched);
    on<RefreshRecentlyWatched>(onRefreshRecentlyWatched);

    // Favorites
    on<LoadFavorites>(onLoadFavorites);
    on<AddFavorite>(onAddFavorite);
    on<RemoveFavorite>(onRemoveFavorite);
    on<ClearFavorites>(onClearFavorites);
    on<RefreshFavorites>(onRefreshFavorites);

    // Movie
    on<LoadMovieDetails>(onLoadMovieDetails);
    on<RefreshMovieDetails>(onRefreshMovieDetails);

    // TV Show
    on<LoadTvShowDetails>(onLoadTvShowDetails);
    on<LoadSeasonEpisodes>(onLoadSeasonEpisodes);
    on<RefreshTvShowDetails>(onRefreshTvShowDetails);

    // Person
    on<LoadPersonMedia>(onLoadPersonMedia);

    // Recent Searches
    on<LoadRecentSearches>(onLoadRecentSearches);
    on<AddRecentSearch>(onAddRecentSearch);
    on<RemoveRecentSearch>(onRemoveRecentSearch);
    on<ClearRecentSearches>(onClearRecentSearches);

    // Streams
    on<ExtractTrailerStreams>(onExtractTrailerStreams);
    on<ExtractMovieStream>(onExtractMovieStream);
    on<ExtractEpisodeStream>(onExtractEpisodeStream);
    on<RemoveMovieStream>(onRemoveMovieStream);
    on<RemoveEpisodeStream>(onRemoveEpisodeStream);
  }

  void init() {
    if (AuthService().isAuthenticated()) {
      add(LoadInitialData());
    }
  }

  @override
  Future<void> close() {
    state.cacheTimer?.cancel();
    return super.close();
  }
}
