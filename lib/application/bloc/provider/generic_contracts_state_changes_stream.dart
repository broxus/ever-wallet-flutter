import 'package:ever_wallet/application/main/browser/events/models/contract_state_changed_event.dart';
import 'package:ever_wallet/data/repositories/generic_contracts_repository.dart';

Stream<ContractStateChangedEvent> genericContractsStateChangesStream(
  GenericContractsRepository genericContractsRepository,
) =>
    genericContractsRepository.stateChangesStream.map(
      (e) => ContractStateChangedEvent(
        address: e.item1,
        state: e.item2,
      ),
    );
