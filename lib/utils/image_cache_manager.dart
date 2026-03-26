import 'dart:ui' as ui;
import 'package:flutter/services.dart';

/// Preloads all game images into ui.Image objects for use in Canvas.drawImage
class ImageCacheManager {
  static final ImageCacheManager _instance = ImageCacheManager._internal();
  factory ImageCacheManager() => _instance;
  ImageCacheManager._internal();

  final Map<String, ui.Image> _cache = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Future<void> loadAll(List<String> paths) async {
    for (final path in paths) {
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _cache[path] = frame.image;
    }
    _loaded = true;
  }

  ui.Image? get(String path) => _cache[path];
}
