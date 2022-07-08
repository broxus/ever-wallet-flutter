import 'package:bloc/bloc.dart';

class SelectedPublicKeyCubit extends Cubit<String?> {
  SelectedPublicKeyCubit(String? initial) : super(initial);

  void select(String publicKey) => emit(publicKey);
}
