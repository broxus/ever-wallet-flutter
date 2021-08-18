import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'suggestion_formatter.dart';

typedef AutofillTextFieldBuilder = Widget Function(
    BuildContext context, TextEditingController controller, FocusNode focus);

class AutofillTextField extends StatefulWidget {
  const AutofillTextField({
    Key? key,
    required this.textFieldBuilder,
    required this.suggestions,
    this.controller,
    this.focusNode,
    this.restorationId,
  }) : super(key: key);

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final AutofillTextFieldBuilder textFieldBuilder;
  final String? restorationId;
  final Iterable<String> Function(String) suggestions;

  @override
  _AutofillTextFieldState createState() => _AutofillTextFieldState();
}

class _AutofillTextFieldState extends State<AutofillTextField> with RestorationMixin {
  RestorableTextEditingController? _controller;
  FocusNode? _focusNode;

  TextEditingController get _effectiveController => widget.controller ?? _controller!.value;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? (_focusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    }
    _effectiveFocusNode.canRequestFocus = true;
  }

  @override
  void didUpdateWidget(covariant AutofillTextField oldWidget) {
    if (widget.controller == null && _controller == null) {
      _createLocalController();
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _focusNode?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _effectiveFocusNode.canRequestFocus = true;
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  Widget build(BuildContext context) => widget.textFieldBuilder(
        context,
        _effectiveController,
        _effectiveFocusNode,
      );

  void _createLocalController([TextEditingValue? value]) {
    assert(_controller == null);
    _controller = value == null ? RestorableTextEditingController() : RestorableTextEditingController.fromValue(value);
    if (restorationId != null || !restorePending) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller_$restorationId');
  }
}
