import 'package:bloc/bloc.dart';

class UrlCubit extends Cubit<String?> {
  UrlCubit() : super(null);

  void setUrl(String? url) => emit(url);
}
