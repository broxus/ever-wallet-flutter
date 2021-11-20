// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shimmer/shimmer.dart';

// import '../../../../../../../../../../domain/blocs/biometry/biometry_get_password_bloc.dart';
// import '../../../../../../../../../../domain/blocs/biometry/biometry_info_bloc.dart';
// import '../../../../../../../../../../domain/blocs/ton_wallet/ton_wallet_deployment_bloc.dart';
// import '../../../../../../../../../../domain/blocs/ton_wallet/ton_wallet_deployment_fees_bloc.dart';
// import '../../../../../../../../../../injection.dart';
// import '../../../../../../../../design/design.dart';
// import '../../../../../../../../design/widgets/crystal_bottom_sheet.dart';
// import '../../../../../../widgets/input_password_modal_body.dart';

// part 'deploy_body.dart';
// part 'password_body.dart';
// part 'result_body.dart';

// class DeployWalletFlow extends StatefulWidget {
//   final String address;
//   final String publicKey;

//   const DeployWalletFlow._({
//     required this.address,
//     required this.publicKey,
//   });

//   static Future<void> start({
//     required BuildContext context,
//     required String address,
//     required String publicKey,
//   }) =>
//       showCrystalBottomSheet(
//         context,
//         draggable: false,
//         padding: EdgeInsets.zero,
//         wrapIntoAnimatedSize: false,
//         avoidBottomInsets: false,
//         body: DeployWalletFlow._(
//           address: address,
//           publicKey: publicKey,
//         ),
//       );

//   @override
//   _DeployWalletFlowState createState() => _DeployWalletFlowState();
// }

// class _DeployWalletFlowState extends State<DeployWalletFlow> {
//   final _pageController = PageController();
//   late TonWalletDeploymentBloc _bloc;

//   @override
//   void initState() {
//     super.initState();
//     _bloc = getIt.get<TonWalletDeploymentBloc>(param1: widget.address);
//   }

//   @override
//   void dispose() {
//     _bloc.close();
//     _pageController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => BlocProvider.value(
//         value: _bloc,
//         child: Builder(
//           builder: (context) => BlocConsumer<TonWalletDeploymentBloc, TonWalletDeploymentState>(
//             listener: (context, state) {
//               FocusScope.of(context).unfocus();
//               state.maybeMap(
//                 initial: (_) => _pageController.openAt(0),
//                 password: (_) async {
//                   String? password;

//                   final biometryInfoBloc = context.read<BiometryInfoBloc>();
//                   final biometryPasswordDataBloc = getIt.get<BiometryGetPasswordBloc>();

//                   if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
//                     biometryPasswordDataBloc.add(BiometryGetPasswordEvent.get(
//                       localizedReason: 'Please authenticate to interact with wallet',
//                       publicKey: widget.publicKey,
//                     ));

//                     password = await biometryPasswordDataBloc.stream
//                         .firstWhere((e) => e is BiometryGetPasswordStateSuccess)
//                         .then((value) => value as BiometryGetPasswordStateSuccess)
//                         .then((value) => value.password);

//                     if (password != null) {
//                       _bloc.add(TonWalletDeploymentEvent.deploy(password));
//                     } else {
//                       _pageController.openAt(1);
//                     }

//                     Future.delayed(const Duration(seconds: 1), () async {
//                       biometryPasswordDataBloc.close();
//                     });
//                   } else {
//                     _pageController.openAt(1);
//                   }
//                 },
//                 sending: (_) => _pageController.openAt(2),
//                 orElse: () => null,
//               );
//             },
//             builder: (context, state) {
//               return ModalFlowBase(
//                 pageController: _pageController,
//                 activeTitle: state.map(
//                   initial: (_) => LocaleKeys.deploy_wallet_modal_available_message.tr(),
//                   password: (_) => LocaleKeys.deploy_wallet_modal_password.tr(),
//                   success: (_) => LocaleKeys.deploy_wallet_modal_success.tr(),
//                   sending: (_) => LocaleKeys.deploy_wallet_modal_deploying.tr(),
//                   error: (error) => error.info,
//                 ),
//                 layoutBuilder: (context, child) => SafeArea(
//                   minimum: const EdgeInsets.symmetric(vertical: 16),
//                   child: child,
//                 ),
//                 pages: [
//                   const DeployBody(),
//                   Padding(
//                     padding: context.keyboardInsets,
//                     child: PasswordBody(publicKey: widget.publicKey),
//                   ),
//                   const ResultBody(),
//                 ],
//               );
//             },
//           ),
//         ),
//       );
// }
