import 'design.dart';

enum CreationActions {
  create,
  import,
  importLegacy,
}

extension CreationActionsDescribe on CreationActions {
  String describe() {
    switch (this) {
      case CreationActions.create:
        return LocaleKeys.new_seed_name_actions_create.tr();
      case CreationActions.import:
        return LocaleKeys.new_seed_name_actions_import.tr();
      case CreationActions.importLegacy:
        return 'Import legacy seed';
    }
  }
}
