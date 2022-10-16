import 'package:collection/collection.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

/// Collection that is used to compare TonWallet that is in progress of subscribing
class TonWalletPendingSubscriptionCollection {
  final TonWalletAsset asset;
  final List<dynamic> transportCollection;

  TonWalletPendingSubscriptionCollection({
    required this.asset,
    required this.transportCollection,
  });

  bool isSameTransport(List<dynamic> otherTransportCollection) =>
      const DeepCollectionEquality().equals(transportCollection, otherTransportCollection);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TonWalletPendingSubscriptionCollection &&
          runtimeType == other.runtimeType &&
          asset == other.asset;

  @override
  int get hashCode => asset.hashCode;
}
