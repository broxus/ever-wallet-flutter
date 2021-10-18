import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';

extension InAppWebViewControllerX on InAppWebViewController {
  Future<void> refresh() async {
    if (Platform.isAndroid) {
      return reload();
    } else if (Platform.isIOS) {
      return loadUrl(urlRequest: URLRequest(url: await getUrl()));
    }
  }

  Future<void> openEmptyPage() async => loadUrl(urlRequest: URLRequest(url: Uri.parse("about:blank")));

  Future<void> parseAndLoadUrl(String url) async {
    try {
      var parsedUrl = Uri.parse(url);

      if (parsedUrl.hasEmptyPath) {
        return openEmptyPage();
      }

      if (parsedUrl.scheme.isEmpty) {
        parsedUrl = Uri.parse("https://www.google.com/search?q=$url");
      }

      return loadUrl(
        urlRequest: URLRequest(url: parsedUrl),
      );
    } catch (_) {
      return;
    }
  }

  Future<String?> getStringifiedUrl() async => getUrl().then((value) => value?.toString());

  Future<String?> getCurrentOrigin() async => getUrl().then((value) => value?.authority);
}
