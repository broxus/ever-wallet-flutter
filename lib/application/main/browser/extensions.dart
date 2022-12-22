import 'dart:async';
import 'dart:io';

import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:validators/validators.dart';

extension InAppWebViewControllerX on InAppWebViewController {
  Future<String> getOrigin() async {
    final url = await getUrl();

    if (url == null) throw Exception('No origin available');

    final origin = url.authority;

    return origin;
  }

  Future<void> goHome() => loadUrl(urlRequest: URLRequest(url: WebUri(aboutBlankPage)));

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
      var siteUrl = WebUri(trimmed);

      if (!siteUrl.hasScheme) siteUrl = WebUri('http://$siteUrl');

      await loadUrl(
        urlRequest: URLRequest(url: siteUrl),
      );
    } else {
      final searchUrl = WebUri(getDuckDuckGoSearchLink(trimmed));

      await loadUrl(
        urlRequest: URLRequest(url: searchUrl),
      );
    }
  }
}
