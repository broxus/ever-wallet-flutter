part of 'token_send_transaction_flow.dart';

class _PasswordBody extends StatefulWidget {
  final String publicKey;

  const _PasswordBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  __PasswordBodyState createState() => __PasswordBodyState();
}

class __PasswordBodyState extends State<_PasswordBody> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: InputPasswordModalBody(
          onSubmit: (password) => context.read<TokenWalletTransferBloc>().add(
                TokenWalletTransferEvent.send(password),
              ),
          buttonText: LocaleKeys.actions_send.tr(),
          publicKey: widget.publicKey,
          isInner: true,
        ),
      );
}
