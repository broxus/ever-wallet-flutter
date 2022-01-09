import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

class ProviderLogger extends ProviderObserver {
  final Logger _logger;

  const ProviderLogger(this._logger);

  @override
  void didAddProvider(ProviderBase provider, Object? value, ProviderContainer container) {
    super.didAddProvider(provider, value, container);
    _logger.d({
      'event': 'didAddProvider',
      'provider': provider,
      'value': value,
    });
  }

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer containers) {
    super.didDisposeProvider(provider, containers);
    _logger.d({
      'event': 'didDisposeProvider',
      'provider': provider,
    });
  }

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue, Object? newValue, ProviderContainer container) {
    super.didUpdateProvider(provider, previousValue, newValue, container);
    _logger.d({
      'event': 'didUpdateProvider',
      'provider': provider,
      'previousValue': previousValue,
      'newValue': newValue,
    });
  }
}
