import 'package:ever_wallet/application/main/browser/events/models/transactions_found_event.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';

Stream<TransactionsFoundEvent> genericContractsTransactionsStream(
  GenericContractsRepository genericContractsRepository,
) =>
    genericContractsRepository.transactionsStream.map(
      (e) => TransactionsFoundEvent(
        address: e.item1,
        transactions: e.item2,
        info: e.item3,
      ),
    );
