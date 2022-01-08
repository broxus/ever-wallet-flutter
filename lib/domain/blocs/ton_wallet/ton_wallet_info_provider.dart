import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';

import '../../../data/repositories/ton_wallet_info_repository.dart';
import '../../../data/services/nekoton_service.dart';
import '../../../injection.dart';

final tonWalletInfoProvider = StreamProvider.family<TonWalletInfo?, String>((ref, address) {
  final stream = getIt.get<NekotonService>().tonWalletsStream.expand((e) => e).where((e) => e.address == address);

  final cached = getIt.get<TonWalletInfoRepository>().get(address);

  return Rx.combineLatest2<TonWallet, ContractState?, TonWallet>(
    stream,
    stream.flatMap((e) => e.onStateChangedStream).cast<ContractState?>().startWith(null),
    (a, b) => a,
  )
      .asyncMap(
        (e) async {
          final tonWalletInfo = TonWalletInfo(
            workchain: e.workchain,
            address: e.address,
            publicKey: e.publicKey,
            walletType: e.walletType,
            contractState: await e.contractState,
            details: e.details,
            custodians: e.custodians,
          );

          await getIt.get<TonWalletInfoRepository>().save(tonWalletInfo);

          return tonWalletInfo;
        },
      )
      .cast<TonWalletInfo?>()
      .startWith(cached);
});
