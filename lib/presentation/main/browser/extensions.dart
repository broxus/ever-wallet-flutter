import 'dart:async';
import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:validators/validators.dart';

import 'utils.dart';

extension InAppWebViewControllerX on InAppWebViewController {
  Future<String?> getOrigin() => getUrl().then((v) => v?.authority);

  Future<void> goHome() => loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));

  Future<void> refresh() async {
    if (Platform.isAndroid) {
      return reload();
    } else if (Platform.isIOS) {
      return loadUrl(urlRequest: URLRequest(url: await getUrl()));
    }
  }

  Future<void> tryLoadUrl(String url) async {
    final trimmed = url.trim();

    if (isURL(trimmed)) {
      var siteUrl = Uri.parse(trimmed);

      if (!siteUrl.hasScheme) siteUrl = Uri.parse('http://$siteUrl');

      await loadUrl(
        urlRequest: URLRequest(url: siteUrl),
      );
    } else {
      final searchUrl = Uri.parse(getDuckDuckGoSearchLink(trimmed));

      await loadUrl(
        urlRequest: URLRequest(url: searchUrl),
      );
    }
  }
}
