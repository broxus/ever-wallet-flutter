import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:tuple/tuple.dart';

// TODO: Write a universal solution for async form validation like a formz
final addBookmarkDialogFormProvider =
    StateNotifierProvider.autoDispose<AddBookmarkDialogFormNotifier, AsyncValue<Tuple2<UnsignedMessage, String>>>(
  (ref) => AddBookmarkDialogFormNotifier(),
);

class AddBookmarkDialogFormNotifier extends StateNotifier<void> {
  AddBookmarkDialogFormNotifier() : super(const Object());

  void onNameChange(String value) {}

  void onUrlChange(String value) {}
}

class AddBookmarkDialogForm {
  final nameInput = NameInput();
  final urlInput = UrlInput();
}

class NameInput {}

class UrlInput {}
