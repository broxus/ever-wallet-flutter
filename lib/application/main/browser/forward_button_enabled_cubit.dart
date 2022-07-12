import 'package:bloc/bloc.dart';

class ForwardButtonEnabledCubit extends Cubit<bool> {
  ForwardButtonEnabledCubit() : super(false);

  void setIsEnabled(bool isEnabled) => emit(isEnabled);
}
