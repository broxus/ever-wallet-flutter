import 'dart:async';

import 'package:crystal/data/dtos/web_metadata_dto.dart';
import 'package:crystal/domain/models/web_metadata.dart';
import 'package:crystal/domain/repositories/web_metadata_repository.dart';
import 'package:favicon/favicon.dart';
import 'package:injectable/injectable.dart';
import 'package:metadata_fetch/metadata_fetch.dart';

@LazySingleton(as: WebMetadataRepository)
class WebMetadataRepositoryImpl implements WebMetadataRepository {
  @override
  Future<WebMetadata> getMetadata(String url) async {
    final data = await MetadataFetch.extract(url);
    final icon = await Favicon.getBest(url);

    final webMetadata = WebMetadataDto(
      url: url,
      title: data?.title,
      icon: icon?.url,
    );

    return webMetadata.toDomain();
  }
}
