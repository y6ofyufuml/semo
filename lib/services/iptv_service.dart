import "dart:async";
import "dart:convert";

import "package:dio/dio.dart";
import "package:logger/logger.dart";
import "package:semo/models/tv_channel.dart";
import "package:shared_preferences/shared_preferences.dart";

class IptvService {
  factory IptvService() => _instance;
  IptvService._internal();

  static final IptvService _instance = IptvService._internal();

  final Logger _logger = Logger();
  final Dio _dio = Dio();
  static const String _cacheKey = "iptv_channels_cache";
  static const String _cacheTimeKey = "iptv_channels_cache_time";
  static const Duration _cacheExpiry = Duration(hours: 24);

  List<TvChannel> _channels = <TvChannel>[];
  List<String> _groups = <String>[];
  List<String> _countries = <String>[];

  List<TvChannel> get channels => _channels;
  List<String> get groups => _groups;
  List<String> get countries => _countries;

  Future<void> loadChannels({bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final bool cacheLoaded = await _loadFromCache();
        if (cacheLoaded) {
          _logger.i("IPTV channels loaded from cache: ${_channels.length}");
          return;
        }
      }

      _logger.i("Fetching IPTV channels from remote...");
      await _fetchChannelsFromRemote();
      await _saveToCache();
      _logger.i("IPTV channels loaded from remote: ${_channels.length}");
    } catch (e, s) {
      _logger.e("Failed to load IPTV channels", error: e, stackTrace: s);
      // Try to load from cache as fallback
      if (forceRefresh) {
        await _loadFromCache();
      }
    }
  }

  Future<bool> _loadFromCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? cachedData = prefs.getString(_cacheKey);
      final int? cacheTime = prefs.getInt(_cacheTimeKey);

      if (cachedData == null || cacheTime == null) {
        return false;
      }

      final DateTime cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
      final bool isExpired = DateTime.now().difference(cacheDateTime) > _cacheExpiry;

      if (isExpired) {
        return false;
      }

      final List<dynamic> jsonList = json.decode(cachedData) as List<dynamic>;
      _channels = jsonList
          .map((dynamic json) => TvChannel.fromJson(json as Map<String, dynamic>))
          .toList();

      _updateGroupsAndCountries();
      return true;
    } catch (e, s) {
      _logger.e("Failed to load IPTV channels from cache", error: e, stackTrace: s);
      return false;
    }
  }

  Future<void> _saveToCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String jsonData = json.encode(_channels.map((TvChannel channel) => channel.toJson()).toList());
      
      await prefs.setString(_cacheKey, jsonData);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e, s) {
      _logger.e("Failed to save IPTV channels to cache", error: e, stackTrace: s);
    }
  }

  Future<void> _fetchChannelsFromRemote() async {
    const String playlistUrl = "https://iptv-org.github.io/iptv/index.m3u";
    
    final Response<String> response = await _dio.get<String>(
      playlistUrl,
      options: Options(
        headers: <String, String>{
          "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
        },
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
      ),
    );

    if (response.data == null) {
      throw Exception("Empty response from IPTV playlist");
    }

    _channels = _parseM3uPlaylist(response.data!);
    _updateGroupsAndCountries();
  }

  List<TvChannel> _parseM3uPlaylist(String m3uContent) {
    final List<TvChannel> channels = <TvChannel>[];
    final List<String> lines = m3uContent.split('\n');
    
    String? currentExtinf;
    
    for (int i = 0; i < lines.length; i++) {
      final String line = lines[i].trim();
      
      if (line.startsWith('#EXTINF:')) {
        currentExtinf = line;
      } else if (line.isNotEmpty && !line.startsWith('#') && currentExtinf != null) {
        try {
          final String entry = '$currentExtinf\n$line';
          final TvChannel channel = TvChannel.fromM3uEntry(entry);
          
          // Filter out NSFW channels
          if (!channel.isNsfw) {
            channels.add(channel);
          }
        } catch (e) {
          _logger.w("Failed to parse channel entry: $e");
        }
        currentExtinf = null;
      }
    }
    
    return channels;
  }

  void _updateGroupsAndCountries() {
    final Set<String> groupSet = <String>{};
    final Set<String> countrySet = <String>{};

    for (final TvChannel channel in _channels) {
      if (channel.group != null && channel.group!.isNotEmpty) {
        groupSet.add(channel.group!);
      }
      if (channel.country != null && channel.country!.isNotEmpty) {
        countrySet.add(channel.country!);
      }
    }

    _groups = groupSet.toList()..sort();
    _countries = countrySet.toList()..sort();
  }

  List<TvChannel> searchChannels(String query) {
    if (query.isEmpty) return _channels;
    
    final String lowerQuery = query.toLowerCase();
    return _channels.where((TvChannel channel) {
      return channel.name.toLowerCase().contains(lowerQuery) ||
             (channel.group?.toLowerCase().contains(lowerQuery) ?? false) ||
             (channel.country?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  List<TvChannel> getChannelsByGroup(String group) {
    return _channels.where((TvChannel channel) => channel.group == group).toList();
  }

  List<TvChannel> getChannelsByCountry(String country) {
    return _channels.where((TvChannel channel) => channel.country == country).toList();
  }

  Future<void> clearCache() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_cacheTimeKey);
      _logger.i("IPTV cache cleared");
    } catch (e, s) {
      _logger.e("Failed to clear IPTV cache", error: e, stackTrace: s);
    }
  }
}