import 'package:favicon/favicon.dart';
import 'package:injectable/injectable.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

@lazySingleton
class MetadataSource {
  Future<String?> getTitle(String url) async {
    final metadata = await MetadataFetch.extract(url);

    if (metadata == null) {
      throw Exception();
    }

    return metadata.title;
  }

  Future<String?> getFavicon(String url) async {
    final icon = await Favicon.getBest(url);

    return icon?.url;
  }
}
