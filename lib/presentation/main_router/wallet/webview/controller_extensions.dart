import 'package:flutter_inappwebview/flutter_inappwebview.dart';

extension InAppWebViewControllerX on InAppWebViewController {
  Future<void> openEmptyPage() async => loadUrl(urlRequest: URLRequest(url: Uri.parse("about:blank")));

  Future<void> parseAndLoadUrl(String url) async {
    try {
      var parsedUrl = Uri.parse(url);

      if (parsedUrl.hasEmptyPath) {
        return openEmptyPage();
      }

      if (!parsedUrl.hasScheme) {
        parsedUrl = Uri.https(parsedUrl.authority, parsedUrl.path);
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
