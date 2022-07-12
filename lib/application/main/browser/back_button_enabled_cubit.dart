import 'package:bloc/bloc.dart';

class BackButtonEnabledCubit extends Cubit<bool> {
  BackButtonEnabledCubit() : super(false);

  void setIsEnabled(bool isEnabled) => emit(isEnabled);
}
