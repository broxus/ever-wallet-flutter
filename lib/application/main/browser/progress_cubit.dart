import 'package:bloc/bloc.dart';

class ProgressCubit extends Cubit<int> {
  ProgressCubit() : super(100);

  void setProgress(int progress) => emit(progress);
}
