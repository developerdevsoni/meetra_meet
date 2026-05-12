import 'package:meetra_meet/models/clan_media_model.dart';

class MediaCacheService {
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;
  MediaCacheService._internal();

  final Map<String, List<ClanMediaModel>> _mediaCache = {};

  void setCache(String clanId, List<ClanMediaModel> media) {
    _mediaCache[clanId] = media;
  }

  List<ClanMediaModel>? getCache(String clanId) {
    return _mediaCache[clanId];
  }

  void clearCache() {
    _mediaCache.clear();
  }
}
