import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:semo/components/anime_card.dart";
import "package:semo/components/spinner.dart";
import "package:semo/models/anime.dart";
import "package:semo/screens/anime_details_screen.dart";
import "package:semo/screens/base_screen.dart";
import "package:semo/services/anime_service.dart";
import "package:semo/utils/navigation_helper.dart";

class AnimeScreen extends BaseScreen {
  const AnimeScreen({super.key});

  @override
  BaseScreenState<AnimeScreen> createState() => _AnimeScreenState();
}

class _AnimeScreenState extends BaseScreenState<AnimeScreen> with TickerProviderStateMixin {
  final AnimeService _animeService = AnimeService();
  late TabController _tabController;
  
  List<Anime> _topAnime = <Anime>[];
  List<Anime> _seasonalAnime = <Anime>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAnimeData();
  }

  Future<void> _loadAnimeData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final List<Future<List<Anime>>> futures = <Future<List<Anime>>>[
        _animeService.getTopAnime(),
        _animeService.getSeasonalAnime(),
      ];

      final List<List<Anime>> results = await Future.wait(futures);
      
      setState(() {
        _topAnime = results[0];
        _seasonalAnime = results[1];
        _isLoading = false;
      });
    } catch (e) {
      logger.e("Failed to load anime data", error: e);
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load anime data"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _navigateToAnimeDetails(Anime anime) {
    NavigationHelper.navigate(
      context,
      AnimeDetailsScreen(anime: anime),
    );
  }

  @override
  String get screenName => "Anime";

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Anime"),
        backgroundColor: Theme.of(context).primaryColor,
        bottom: TabBar(
          controller: _tabController,
          tabs: const <Tab>[
            Tab(
              icon: Icon(Icons.trending_up),
              text: "Top Anime",
            ),
            Tab(
              icon: Icon(Icons.schedule),
              text: "This Season",
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnimeData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: Spinner())
          : TabBarView(
              controller: _tabController,
              children: <Widget>[
                _buildAnimeGrid(_topAnime),
                _buildAnimeGrid(_seasonalAnime),
              ],
            ),
    );
  }

  Widget _buildAnimeGrid(List<Anime> animeList) {
    if (animeList.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(
              FontAwesomeIcons.film,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              "No anime found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: animeList.length,
      itemBuilder: (BuildContext context, int index) {
        final Anime anime = animeList[index];
        return AnimeCard(
          anime: anime,
          onTap: () => _navigateToAnimeDetails(anime),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}