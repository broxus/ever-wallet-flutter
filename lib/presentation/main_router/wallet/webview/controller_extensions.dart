import 'dart:async';
import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rxdart/subjects.dart';

extension InAppWebViewControllerX on InAppWebViewController {
  static final _errorsSubject = PublishSubject<_LoadingError>();
  static final _loadedUrlsSubject = PublishSubject<Uri?>();

  void onError(Uri? url, int code, String message) => _errorsSubject.add(_LoadingError(url, code, message));

  void onLoaded(Uri? url) => _loadedUrlsSubject.add(url);

  Future<void> refresh() async {
    if (Platform.isAndroid) {
      return reload();
    } else if (Platform.isIOS) {
      return loadUrl(urlRequest: URLRequest(url: await getUrl()));
    }
  }

  Future<void> openInitialPage() async =>
      loadUrl(urlRequest: URLRequest(url: Uri.parse("https://l1.broxus.com/dapps")));

  Future<void> parseAndLoadUrl(String url) async {
    try {
      var parsedUrl = Uri.parse(url);

      if (parsedUrl.toString().isEmpty) {
        await openInitialPage();
        return;
      }

      if (parsedUrl.scheme.isEmpty) {
        parsedUrl = Uri.https(url, '');
      }

      try {
        await loadUrlWithResult(
          urlRequest: URLRequest(url: parsedUrl),
        );
        return;
      } catch (_) {
        parsedUrl = Uri.http(url, '');

        try {
          await loadUrlWithResult(
            urlRequest: URLRequest(url: parsedUrl),
          );
          return;
        } catch (_) {
          parsedUrl = Uri.parse("https://www.google.com/search?q=$url");

          await loadUrl(
            urlRequest: URLRequest(url: parsedUrl),
          );
          return;
        }
      }
    } catch (_) {
      return;
    }
  }

  Future<String?> getStringifiedUrl() async => getUrl().then((value) => value?.toString());

  Future<String?> getCurrentOrigin() async => getUrl().then((value) => value?.authority);

  Future<void> loadUrlWithResult({
    required URLRequest urlRequest,
    Uri? iosAllowingReadAccessTo,
  }) async {
    final completer = Completer();

    late final StreamSubscription _errorsStreamSubscription;

    _errorsStreamSubscription = _errorsSubject.listen((value) {
      if (value.url?.scheme == urlRequest.url?.scheme && value.url?.authority == urlRequest.url?.authority) {
        if (!completer.isCompleted) {
          completer.completeError(Exception(value.message));
        }
        _errorsStreamSubscription.cancel();
      }
    });

    late final StreamSubscription _loadedUrlsStreamSubscription;

    _loadedUrlsStreamSubscription = _loadedUrlsSubject.listen((value) {
      if (value?.scheme == urlRequest.url?.scheme && value?.authority == urlRequest.url?.authority) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        _loadedUrlsStreamSubscription.cancel();
      }
    });

    loadUrl(
      urlRequest: urlRequest,
      iosAllowingReadAccessTo: iosAllowingReadAccessTo,
    );

    return completer.future;
  }
}

class _LoadingError {
  Uri? url;
  int code;
  String message;

  _LoadingError(
    this.url,
    this.code,
    this.message,
  );
}
