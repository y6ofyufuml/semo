import "package:flutter/material.dart";
import "package:infinite_scroll_pagination/infinite_scroll_pagination.dart";
import "package:build_x/components/genre_card.dart";
import "package:build_x/components/horizontal_media_list.dart";
import "package:build_x/enums/media_type.dart";
import "package:build_x/models/genre.dart";
import "package:build_x/screens/view_all_screen.dart";
import "package:build_x/utils/navigation_helper.dart";

class GenresList extends StatelessWidget {
  const GenresList({
    super.key,
    required this.genres,
    required this.mediaPagingControllers,
    required this.mediaType,
  });

  final List<Genre> genres;
  final Map<String, PagingController<int, dynamic>> mediaPagingControllers;
  final MediaType mediaType;

  @override
  Widget build(BuildContext context) => HorizontalMediaList<Genre>(
    title: "Genres",
    items: genres,
    itemBuilder: (BuildContext context, Genre genre, int index) => Container(
      margin: EdgeInsets.only(
        right: index < genres.length - 1 ? 18 : 0,
      ),
      child: GenreCard(
        genre: genre,
        mediaType: mediaType,
        onTap: () => NavigationHelper.navigate(
          context,
          ViewAllScreen(
            title: genre.name,
            pagingController: mediaPagingControllers[genre.id.toString()]!,
            mediaType: mediaType,
          ),
        ),
      ),
    ),
  );
}
