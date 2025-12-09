import "package:flutter/material.dart";
import "package:font_awesome_flutter/font_awesome_flutter.dart";
import "package:build_x/components/spinner.dart";
import "package:build_x/components/tv_channel_card.dart";
import "package:build_x/models/tv_channel.dart";
import "package:build_x/screens/base_screen.dart";
import "package:build_x/screens/tv_channel_player_screen.dart";
import "package:build_x/services/iptv_service.dart";
import "package:build_x/utils/navigation_helper.dart";

class TvChannelsScreen extends BaseScreen {
  const TvChannelsScreen({super.key});

  @override
  BaseScreenState<TvChannelsScreen> createState() => _TvChannelsScreenState();
}

class _TvChannelsScreenState extends BaseScreenState<TvChannelsScreen> {
  final IptvService _iptvService = IptvService();
  final TextEditingController _searchController = TextEditingController();
  
  List<TvChannel> _filteredChannels = <TvChannel>[];
  String? _selectedGroup;
  String? _selectedCountry;
  bool _isGridView = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  Future<void> _loadChannels() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _iptvService.loadChannels();
      _filteredChannels = _iptvService.channels;
    } catch (e) {
      logger.e("Failed to load TV channels", error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to load TV channels"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _filterChannels() {
    List<TvChannel> channels = _iptvService.channels;

    // Apply search filter
    if (_searchController.text.isNotEmpty) {
      channels = _iptvService.searchChannels(_searchController.text);
    }

    // Apply group filter
    if (_selectedGroup != null) {
      channels = channels.where((TvChannel channel) => channel.group == _selectedGroup).toList();
    }

    // Apply country filter
    if (_selectedCountry != null) {
      channels = channels.where((TvChannel channel) => channel.country == _selectedCountry).toList();
    }

    setState(() {
      _filteredChannels = channels;
    });
  }

  void _playChannel(TvChannel channel) {
    navigate(TvChannelPlayerScreen(channel: channel));
  }

  @override
  String get screenName => "TV Channels";

  @override
  Widget buildContent(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("TV Channels"),
        backgroundColor: Theme.of(context).primaryColor,
        actions: <Widget>[
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _iptvService.loadChannels(forceRefresh: true);
              _filterChannels();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                _buildSearchAndFilters(),
                Expanded(
                  child: _buildChannelsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          // Search bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search channels...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _filterChannels();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (String value) {
              _filterChannels();
            },
          ),
          const SizedBox(height: 12),
          // Filters
          Row(
            children: <Widget>[
              Expanded(
                child: _buildGroupFilter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildCountryFilter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGroupFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedGroup,
      decoration: InputDecoration(
        labelText: "Group",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(
          value: null,
          child: Text("All Groups"),
        ),
        ..._iptvService.groups.map((String group) => DropdownMenuItem<String>(
              value: group,
              child: Text(
                group,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
      onChanged: (String? value) {
        setState(() {
          _selectedGroup = value;
        });
        _filterChannels();
      },
    );
  }

  Widget _buildCountryFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: "Country",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: <DropdownMenuItem<String>>[
        const DropdownMenuItem<String>(
          value: null,
          child: Text("All Countries"),
        ),
        ..._iptvService.countries.map((String country) => DropdownMenuItem<String>(
              value: country,
              child: Text(
                country,
                overflow: TextOverflow.ellipsis,
              ),
            )),
      ],
      onChanged: (String? value) {
        setState(() {
          _selectedCountry = value;
        });
        _filterChannels();
      },
    );
  }

  Widget _buildChannelsList() {
    if (_filteredChannels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FaIcon(
              FontAwesomeIcons.tv,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              "No channels found",
              style: TextStyle(
                fontSize: 18,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      );
    }

    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _filteredChannels.length,
        itemBuilder: (BuildContext context, int index) {
          final TvChannel channel = _filteredChannels[index];
          return TvChannelGridCard(
            channel: channel,
            onTap: () => _playChannel(channel),
          );
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _filteredChannels.length,
      itemBuilder: (BuildContext context, int index) {
        final TvChannel channel = _filteredChannels[index];
        return TvChannelCard(
          channel: channel,
          onTap: () => _playChannel(channel),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}