import 'package:bloc/bloc.dart';

class SelectedPublicKeyCubit extends Cubit<String> {
  SelectedPublicKeyCubit(super.initial);

  void select(String publicKey) => emit(publicKey);
}
