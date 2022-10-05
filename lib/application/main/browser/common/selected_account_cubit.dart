import 'package:bloc/bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SelectedAccountCubit extends Cubit<AssetsList?> {
  SelectedAccountCubit(super.initial);

  void select(AssetsList account) => emit(account);
}
