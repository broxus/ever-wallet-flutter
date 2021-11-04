part of 'deploy_wallet_flow.dart';

class PasswordBody extends StatefulWidget {
  final String publicKey;

  const PasswordBody({
    Key? key,
    required this.publicKey,
  }) : super(key: key);

  @override
  _PasswordBodyState createState() => _PasswordBodyState();
}

class _PasswordBodyState extends State<PasswordBody> {
  @override
  Widget build(BuildContext context) => InputPasswordModalBody(
        onSubmit: (password) => context.read<TonWalletDeploymentBloc>().add(
              TonWalletDeploymentEvent.deploy(password),
            ),
        buttonText: LocaleKeys.actions_send.tr(),
        publicKey: widget.publicKey,
        isInner: true,
      );
}
