import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rxdart/rxdart.dart';

import '../../../injection.dart';
import '../../../logger.dart';
import '../../data/models/site_meta_data.dart';
import '../../data/repositories/sites_meta_data_repository.dart';

final siteMetaDataProvider = StreamProvider.autoDispose.family<SiteMetaData, String>(
  (ref, url) =>
      getIt.get<SitesMetaDataRepository>().getSiteMetaData(url).doOnError((err, st) => logger.e(err, err, st)),
);
