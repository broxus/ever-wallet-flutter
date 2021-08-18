part of 'send_transaction_flow.dart';

class _EnterAddressBody extends StatefulWidget {
  const _EnterAddressBody({
    Key? key,
    required this.clipboard,
    this.balance,
    this.amount,
    this.address,
    this.comment,
  }) : super(key: key);

  final ValueNotifier<String?> clipboard;

  final String? amount;
  final String? address;
  final String? comment;
  final String? balance;

  @override
  __EnterAddressBodyState createState() => __EnterAddressBodyState();
}

class __EnterAddressBodyState extends State<_EnterAddressBody> {
  final _scrollController = ScrollController();

  final _amountFocus = FocusNode();
  final _addressFocus = FocusNode();
  final _commentFocus = FocusNode();

  late final TextEditingController _amountController;
  late final TextEditingController _addressController;
  late final TextEditingController _commentController;

  ValueNotifier<String?> get _clipboard => widget.clipboard;

  @override
  void initState() {
    _amountController = TextEditingController(text: widget.amount?.replaceAll(',', ''));
    _addressController = TextEditingController(text: widget.address);
    _commentController = TextEditingController(text: widget.comment);
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _amountController.dispose();
    _addressController.dispose();
    _commentController.dispose();
    _amountFocus.dispose();
    _addressFocus.dispose();
    _commentFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CrystalTextField(
                      controller: _amountController,
                      focusNode: _amountFocus,
                      hintText: LocaleKeys.send_transaction_modal_input_hints_amount.tr(),
                      maxLength: 64,
                      scrollPadding: const EdgeInsets.only(bottom: 24.0),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      formatters: [AmountInputFormatter()],
                    ),
                    const CrystalDivider(height: 8.0),
                    if (widget.balance != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          LocaleKeys.send_transaction_modal_input_balance.tr(
                            args: [
                              widget.balance!,
                              'TON',
                            ],
                          ),
                          style: const TextStyle(
                            fontSize: 14.0,
                            letterSpacing: 0.75,
                            color: CrystalColor.fontSecondaryDark,
                          ),
                        ),
                      ),
                    const CrystalDivider(height: 16.0),
                    AnimatedBuilder(
                      animation: Listenable.merge([_addressController, _clipboard]),
                      builder: (context, _) => CrystalTextField(
                        key: const ValueKey('send_transaction_address_text_field'),
                        controller: _addressController,
                        focusNode: _addressFocus,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        hintText: LocaleKeys.send_transaction_modal_input_hints_address.tr(),
                        formatters: [
                          FilteringTextInputFormatter.allow(RegExp('[:0-9a-zA-Z]')),
                        ],
                        validator: (value) {
                          if (value != null && validateAddress(value)) {
                            return null;
                          } else {
                            return LocaleKeys.fields_validation_errors_wrong_address.tr();
                          }
                        },
                        scrollPadding: const EdgeInsets.only(bottom: 24.0),
                        maxLength: 128,
                        suffix: _addressController.text.isEmpty && _clipboard.value != null
                            ? _suffixText(
                                text: LocaleKeys.send_transaction_modal_input_actions_paste.tr(),
                                onTap: () {
                                  _addressController.text = _clipboard.value!;
                                  _addressController.selection =
                                      TextSelection.collapsed(offset: _clipboard.value!.length);
                                },
                              )
                            : null,
                      ),
                    ),
                    const CrystalDivider(height: 16.0),
                    CrystalTextField(
                      controller: _commentController,
                      focusNode: _commentFocus,
                      scrollPadding: const EdgeInsets.only(bottom: 24.0),
                      hintText: LocaleKeys.send_transaction_modal_input_hints_comment.tr(),
                    ),
                    const CrystalDivider(height: 24.0),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AnimatedBuilder(
              animation: Listenable.merge([_amountController, _addressController]),
              builder: (context, _) => CrystalButton(
                enabled: _amountController.text.isNotEmpty && _addressController.text.isNotEmpty,
                text: LocaleKeys.actions_send.tr(),
                onTap: _send,
              ),
            ),
          ),
        ],
      );

  Widget _suffixText({
    required String text,
    double paddingLeft = 16.0,
    double paddingRight = 16.0,
    VoidCallback? onTap,
  }) =>
      AnimatedSwitcher(
        duration: kThemeAnimationDuration,
        child: onTap != null
            ? IntrinsicWidth(
                child: Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onTap,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(paddingLeft, 14.0, paddingRight, 14.0),
                      child: Text(
                        text,
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                          color: CrystalColor.accent,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      );

  void _send() {
    context.read<TonWalletTransferBloc>().add(
          TonWalletTransferEvent.prepareTransfer(
            destination: _addressController.text,
            amount: _amountController.text,
            comment: _commentController.text,
          ),
        );
  }
}
