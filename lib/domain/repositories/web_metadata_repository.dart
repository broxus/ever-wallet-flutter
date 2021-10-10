import '../models/web_metadata.dart';

abstract class WebMetadataRepository {
  Future<WebMetadata> getMetadata(String url);
}
