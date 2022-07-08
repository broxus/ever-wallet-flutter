import 'package:bloc/bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

class SelectedAccountCubit extends Cubit<AssetsList?> {
  SelectedAccountCubit(AssetsList? initial) : super(initial);

  void select(AssetsList account) => emit(account);
}
