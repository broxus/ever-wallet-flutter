import 'dart:async';
import 'dart:io';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:rxdart/subjects.dart';

import '../../../logger.dart';

class CustomInAppWebViewController {
  final InAppWebViewController controller;
  final _errorsSubject = PublishSubject<_LoadingError>();
  final _loadedUrlsSubject = PublishSubject<Uri?>();

  CustomInAppWebViewController(this.controller);

  Future<bool> canGoBack() => controller.canGoBack();

  Future<void> goBack() => controller.goBack();

  Future<bool> canGoForward() => controller.canGoForward();

  Future<void> goForward() => controller.goForward();

  Future<void> goHome() => controller.loadUrl(urlRequest: URLRequest(url: Uri.parse('about:blank')));

  Future<void> reload() => controller.reload();

  Future<Uri?> getUrl() => controller.getUrl();

  Future<String?> getTitle() => controller.getTitle();

  Future<List<Favicon>> getFavicons() => controller.getFavicons();

  void addJavaScriptHandler({
    required String handlerName,
    required JavaScriptHandlerCallback callback,
  }) =>
      controller.addJavaScriptHandler(
        handlerName: handlerName,
        callback: callback,
      );

  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async =>
      controller.evaluateJavascript(
        source: source,
        contentWorld: contentWorld,
      );

  void onError(Uri? url, int code, String message) => _errorsSubject.add(_LoadingError(url, code, message));

  void onLoaded(Uri? url) => _loadedUrlsSubject.add(url);

  Future<void> refresh() async {
    if (Platform.isAndroid) {
      return controller.reload();
    } else if (Platform.isIOS) {
      return controller.loadUrl(urlRequest: URLRequest(url: await controller.getUrl()));
    }
  }

  Future<void> parseAndLoadUrl(String url) async {
    try {
      var parsedUrl = Uri.parse(url.trim());

      if (await controller.getUrl() == parsedUrl) return;

      if (parsedUrl.toString().isEmpty) {
        await goHome();
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
          parsedUrl = Uri.parse('https://www.google.com/search?q=$url');

          await controller.loadUrl(
            urlRequest: URLRequest(url: parsedUrl),
          );
          return;
        }
      }
    } catch (err, st) {
      logger.e('Controller', err, st);
      return;
    }
  }

  Future<void> loadUrlWithResult({
    required URLRequest urlRequest,
    Uri? iosAllowingReadAccessTo,
  }) async {
    final completer = Completer<void>();

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

    controller.loadUrl(
      urlRequest: urlRequest,
      iosAllowingReadAccessTo: iosAllowingReadAccessTo,
    );

    return completer.future;
  }

  void dispose() {
    _errorsSubject.close();
    _loadedUrlsSubject.close();
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
