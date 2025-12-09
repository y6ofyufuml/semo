class TvChannel {
  final String id;
  final String name;
  final String url;
  final String? logo;
  final String? group;
  final String? country;
  final String? language;
  final bool isNsfw;

  const TvChannel({
    required this.id,
    required this.name,
    required this.url,
    this.logo,
    this.group,
    this.country,
    this.language,
    this.isNsfw = false,
  });

  factory TvChannel.fromM3uEntry(String entry) {
    final RegExp extinf = RegExp(r'#EXTINF:(-?\d+)(.*)');
    final RegExp tvgId = RegExp(r'tvg-id="([^"]*)"');
    final RegExp tvgName = RegExp(r'tvg-name="([^"]*)"');
    final RegExp tvgLogo = RegExp(r'tvg-logo="([^"]*)"');
    final RegExp groupTitle = RegExp(r'group-title="([^"]*)"');
    final RegExp tvgCountry = RegExp(r'tvg-country="([^"]*)"');
    final RegExp tvgLanguage = RegExp(r'tvg-language="([^"]*)"');
    
    final List<String> lines = entry.trim().split('\n');
    if (lines.length < 2) {
      throw Exception('Invalid M3U entry format');
    }
    
    final String extinfLine = lines[0];
    final String url = lines[1];
    
    final Match? extinfMatch = extinf.firstMatch(extinfLine);
    if (extinfMatch == null) {
      throw Exception('Invalid EXTINF line');
    }
    
    final String attributes = extinfMatch.group(2) ?? '';
    final String channelName = attributes.split(',').last.trim();
    
    final String? id = tvgId.firstMatch(attributes)?.group(1);
    final String? logo = tvgLogo.firstMatch(attributes)?.group(1);
    final String? group = groupTitle.firstMatch(attributes)?.group(1);
    final String? country = tvgCountry.firstMatch(attributes)?.group(1);
    final String? language = tvgLanguage.firstMatch(attributes)?.group(1);
    
    // Check if channel is NSFW based on group or name
    final bool isNsfw = (group?.toLowerCase().contains('xxx') ?? false) ||
                       (group?.toLowerCase().contains('adult') ?? false) ||
                       (channelName.toLowerCase().contains('xxx')) ||
                       (channelName.toLowerCase().contains('adult'));
    
    return TvChannel(
      id: id ?? channelName.hashCode.toString(),
      name: channelName,
      url: url,
      logo: logo,
      group: group,
      country: country,
      language: language,
      isNsfw: isNsfw,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'url': url,
      'logo': logo,
      'group': group,
      'country': country,
      'language': language,
      'isNsfw': isNsfw,
    };
  }

  factory TvChannel.fromJson(Map<String, dynamic> json) {
    return TvChannel(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      logo: json['logo'] as String?,
      group: json['group'] as String?,
      country: json['country'] as String?,
      language: json['language'] as String?,
      isNsfw: json['isNsfw'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TvChannel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'TvChannel(id: $id, name: $name, group: $group, country: $country)';
  }
}