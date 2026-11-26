import 'package:flutter/painting.dart';

class TPArtwork {
  static AssetImage provider(String name) {
    if (name.startsWith('assets/image/')) return AssetImage(name);

    final key = name.split('/').last.replaceAll('.webp', '');
    return AssetImage('assets/images/$key.webp');
  }
}
