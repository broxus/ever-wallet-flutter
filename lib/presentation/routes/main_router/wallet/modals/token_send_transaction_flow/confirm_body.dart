// part of 'token_send_transaction_flow.dart';

// class _ConfirmBody extends StatelessWidget {
//   final Function()? onBack;
//   const _ConfirmBody({
//     Key? key,
//     this.onBack,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) => Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: BlocBuilder<TokenWalletTransferBloc, TokenWalletTransferState>(
//           buildWhen: (prev, next) => next.maybeMap(
//             messagePrepared: (_) => true,
//             orElse: () => false,
//           ),
//           builder: (context, state) {
//             final isInsufficientFunds = state.maybeMap(
//               orElse: () => false,
//             );

//             return Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Flexible(
//                   child: ColoredBox(
//                     color: CrystalColor.grayBackground,
//                     child: FadingEdgeScrollView.fromSingleChildScrollView(
//                       shouldDisposeScrollController: true,
//                       child: SingleChildScrollView(
//                         controller: ScrollController(),
//                         padding: const EdgeInsets.all(16),
//                         child: Column(
//                           mainAxisSize: MainAxisSize.min,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             InformationField(
//                               title: LocaleKeys.fields_recipient.tr(),
//                               value: state.maybeMap(
//                                 messagePrepared: (info) => info.destination,
//                                 orElse: () => '',
//                               ),
//                             ),
//                             const Flexible(child: CrystalDivider(height: 16)),
//                             const Divider(height: 1, thickness: 1),
//                             const Flexible(child: CrystalDivider(height: 16)),
//                             InformationField(
//                               title: LocaleKeys.fields_amount.tr(),
//                               value: LocaleKeys.send_transaction_modal_input_value.tr(args: [
//                                 state.maybeMap(
//                                   messagePrepared: (info) => info.tokens,
//                                   orElse: () => '',
//                                 ),
//                                 state.maybeMap(
//                                   messagePrepared: (info) => info.currency,
//                                   orElse: () => '',
//                                 ),
//                               ]),
//                               error: isInsufficientFunds
//                                   ? LocaleKeys.send_transaction_modal_confirm_errors_insufficient_funds.tr()
//                                   : '',
//                             ),
//                             const Flexible(child: CrystalDivider(height: 16)),
//                             getFeesInfo(context),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const CrystalDivider(height: 24),
//                 Row(
//                   children: [
//                     if (onBack != null)
//                       CrystalButton(
//                         type: CrystalButtonType.outline,
//                         text: LocaleKeys.actions_back.tr(),
//                         onTap: onBack,
//                       ),
//                     if (!isInsufficientFunds) ...[
//                       const CrystalDivider(width: 16),
//                       Expanded(
//                         child: getConfirmButton(context),
//                       ),
//                     ],
//                   ],
//                 )
//               ],
//             );
//           },
//         ),
//       );

//   Widget getFeesInfo(BuildContext context) => BlocBuilder<TokenWalletFeesBloc, TokenWalletFeesState>(
//         bloc: context.watch<TokenWalletTransferBloc>().feesBloc,
//         builder: (context, TokenWalletFeesState state) {
//           return AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: InformationField(
//               title: LocaleKeys.fields_blockchain_fee.tr(),
//               isLoading: state.maybeMap(orElse: () => false, loading: (_) => true),
//               value: LocaleKeys.send_transaction_modal_input_value.tr(args: [
//                 '~${state.maybeMap(
//                   ready: (info) => info.fees,
//                   insufficientFunds: (info) => info.fees,
//                   insufficientOwnerFunds: (info) => info.fees,
//                   orElse: () => '',
//                 )}',
//                 'TON',
//               ]),
//               error: state.maybeMap(
//                   orElse: () => '',
//                   insufficientFunds: (_) => LocaleKeys.send_transaction_modal_confirm_errors_insufficient_funds.tr(),
//                   insufficientOwnerFunds: (_) =>
//                       LocaleKeys.send_transaction_modal_confirm_errors_insufficient_owner_funds.tr(),
//                   error: (info) => info.info),
//             ),
//           );
//         },
//       );

//   Widget getConfirmButton(BuildContext context) => BlocBuilder<TokenWalletFeesBloc, TokenWalletFeesState>(
//         bloc: context.watch<TokenWalletTransferBloc>().feesBloc,
//         builder: (context, state) {
//           return CrystalButton(
//               text: LocaleKeys.send_transaction_modal_confirm_title.tr(),
//               onTap: state.maybeMap(
//                 orElse: () => null,
//                 ready: (_) => () => context.read<TokenWalletTransferBloc>().add(
//                       const TokenWalletTransferEvent.goToPassword(),
//                     ),
//               ));
//         },
//       );
// }
