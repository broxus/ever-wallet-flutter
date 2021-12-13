import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tuple/tuple.dart';

import '../../../data/services/nekoton_service.dart';
import '../../../logger.dart';

part 'ton_wallet_sent_transactions_bloc.freezed.dart';

@injectable
class TonWalletSentTransactionsBloc extends Bloc<_Event, List<Tuple2<PendingTransaction, Transaction?>>> {
  final NekotonService _nekotonService;
  final _errorsSubject = PublishSubject<Exception>();
  StreamSubscription? _streamSubscription;
  StreamSubscription? _onMessageSentSubscription;

  TonWalletSentTransactionsBloc(this._nekotonService) : super(const []);

  @override
  Future<void> close() {
    _errorsSubject.close();
    _streamSubscription?.cancel();
    _onMessageSentSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<List<Tuple2<PendingTransaction, Transaction?>>> mapEventToState(_Event event) async* {
    // yield [
    //   Tuple2(
    //     PendingTransaction(
    //       messageHash: '0xDEAFBEAF',
    //       bodyHash: '0xDEAFBEAF',
    //       src: '0:9c1811c276eec34c6d690cfacf8ceb8f4beb50bb5df73c2b1b2be633c03a19cc',
    //       expireAt: (DateTime.now().millisecondsSinceEpoch + 1000000000) ~/ 1000,
    //     ),
    //     Transaction(
    //       id: const TransactionId(
    //         lt: 'lt',
    //         hash: 'hash',
    //       ),
    //       prevTransactionId: const TransactionId(
    //         lt: 'lt',
    //         hash: 'hash',
    //       ),
    //       createdAt: (DateTime.now().millisecondsSinceEpoch + 1000000000) ~/ 1000,
    //       aborted: false,
    //       exitCode: 0,
    //       origStatus: AccountStatus.active,
    //       endStatus: AccountStatus.active,
    //       totalFees: '100099999999',
    //       inMessage: const Message(
    //         src: '0:9c1811c276eec34c6d690cfacf8ceb8f4beb50bb5df73c2b1b2be633c03a19cc',
    //         dst: '0:9c1811c276eec34c6d690cfacf8ceb8f4beb50bb5df73c2b1b2be633c03a19cc',
    //         value: '1000000000000',
    //         bounce: true,
    //         bounced: false,
    //         body: '0xDEAFBEAF',
    //         bodyHash: '0xDEAFBEAF',
    //       ),
    //       outMessages: [
    //         const Message(
    //           src: '0:9c1811c276eec34c6d690cfacf8ceb8f4beb50bb5df73c2b1b2be633c03a19cc',
    //           dst: '0:9c1811c276eec34c6d690cfacf8ceb8f4beb50bb5df73c2b1b2be633c03a19cc',
    //           value: '1000000000000',
    //           bounce: true,
    //           bounced: false,
    //           body: '0xDEAFBEAF',
    //           bodyHash: '0xDEAFBEAF',
    //         ),
    //       ],
    //     ),
    //   ),
    // ];

    // return;

    try {
      if (event is _Load) {
        yield const [];

        final address = event.address;

        _streamSubscription?.cancel();
        _onMessageSentSubscription?.cancel();

        _streamSubscription = _nekotonService.tonWalletsStream
            .expand((e) => e)
            .where((e) => e.address == address)
            .distinct()
            .listen((event) {
          final tonWallet = event;

          _onMessageSentSubscription?.cancel();

          _onMessageSentSubscription = tonWallet.onMessageSentStream.listen(
            (event) => add(
              _LocalEvent.update(event),
            ),
          );
        });
      } else if (event is _Update) {
        yield event.transactions;
      }
    } on Exception catch (err, st) {
      logger.e(err, err, st);
      _errorsSubject.add(err);
    }
  }

  Stream<Exception> get errorsStream => _errorsSubject.stream;
}

abstract class _Event {}

@freezed
class _LocalEvent extends _Event with _$_LocalEvent {
  const factory _LocalEvent.update(List<Tuple2<PendingTransaction, Transaction?>> transactions) = _Update;
}

@freezed
class TonWalletSentTransactionsEvent extends _Event with _$TonWalletSentTransactionsEvent {
  const factory TonWalletSentTransactionsEvent.load(String address) = _Load;
}
