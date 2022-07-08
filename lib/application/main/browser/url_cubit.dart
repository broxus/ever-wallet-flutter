import 'package:bloc/bloc.dart';

class UrlCubit extends Cubit<Uri?> {
  UrlCubit() : super(null);

  void setUrl(Uri? url) => emit(url);
}
