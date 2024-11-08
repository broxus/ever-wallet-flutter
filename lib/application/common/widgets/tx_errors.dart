import 'package:ever_wallet/application/common/constants.dart';
import 'package:ever_wallet/application/common/extensions.dart';
import 'package:ever_wallet/application/common/general/field/switch_field.dart';
import 'package:ever_wallet/application/common/general/flushbar.dart';
import 'package:ever_wallet/application/common/widgets/transport_type_builder.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/application/util/styles.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class TxErrors extends StatelessWidget {
  const TxErrors({
    required this.errors,
    required this.isConfirmed,
    required this.onConfirm,
    super.key,
  });

  final List<TxTreeSimulationErrorItem> errors;
  final bool isConfirmed;
  final ValueChanged<bool> onConfirm;

  @override
  Widget build(BuildContext context) => TransportTypeBuilderWidget(
        builder: (context, isEver) {
          final canFixTxError = errors.any(
            (item) => item.error.code == -14 || item.error.code == -37,
          );

          return DecoratedBox(
            decoration: BoxDecoration(
              color: ColorsRes.redBackground,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tokens may be lost!',
                    style: StylesRes.medium16.copyWith(
                      color: ColorsRes.red400Primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final item in errors) _ErrorMessage(item: item),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      style: StylesRes.captionText.copyWith(
                        color: ColorsRes.red400Primary,
                      ),
                      children: [
                        if (canFixTxError)
                          TextSpan(
                            text:
                                'Send 0.2 ${isEver ? kEverTicker : kVenomTicker} to this address or contact ',
                          )
                        else
                          const TextSpan(
                            text: 'Contact ',
                          ),
                        TextSpan(
                          text: 'technical support',
                          style: StylesRes.captionText.copyWith(
                            color: ColorsRes.bluePrimary400,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () async {
                              await launchUrl(
                                Uri.parse(kBroxusSupportLink),
                                mode: LaunchMode.externalApplication,
                              );
                            },
                        ),
                        const TextSpan(text: '.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Send it anyway. I accept the risks.',
                          style: StylesRes.captionText.copyWith(
                            color: ColorsRes.red400Primary,
                          ),
                        ),
                      ),
                      const Gap(16),
                      EWSwitchField(
                        value: isConfirmed,
                        onChanged: onConfirm,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
}

class _ErrorMessage extends StatefulWidget {
  const _ErrorMessage({required this.item});

  final TxTreeSimulationErrorItem item;

  @override
  State<_ErrorMessage> createState() => _ErrorMessageState();
}

class _ErrorMessageState extends State<_ErrorMessage> {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: StylesRes.captionText.copyWith(
          color: ColorsRes.red400Primary,
        ),
        children: _buildError(),
      ),
    );
  }

  List<InlineSpan> _buildError() {
    final address = TextSpan(
      text: widget.item.address.ellipseAddress(),
      style: StylesRes.captionText.copyWith(
        color: ColorsRes.red400Primary,
        fontWeight: FontWeight.w600,
      ),
      recognizer: TapGestureRecognizer()..onTap = _onTap,
    );

    switch (widget.item.error.type) {
      case TxTreeSimulationErrorType.computePhase:
        return [
          const TextSpan(
            text:
                'Transaction tree execution may fail, because execution failed on ',
          ),
          address,
          TextSpan(
            text: ' with exit code ${widget.item.error.code}.',
          ),
        ];
      case TxTreeSimulationErrorType.actionPhase:
        return [
          const TextSpan(
            text:
                'Transaction tree execution may fail, because action phase failed on ',
          ),
          address,
          TextSpan(
            text: ' with exit code ${widget.item.error.code}.',
          ),
        ];
      case TxTreeSimulationErrorType.frozen:
        return [
          const TextSpan(
            text: 'Transaction tree execution may fail, because account ',
          ),
          address,
          const TextSpan(
            text: ' will be frozen due to storage fee debt.',
          ),
        ];
      case TxTreeSimulationErrorType.deleted:
        return [
          const TextSpan(
            text: 'Transaction tree execution may fail, because account ',
          ),
          address,
          const TextSpan(
            text: ' will be deleted due to storage fee debt.',
          ),
        ];
    }
  }

  void _onTap() {
    Clipboard.setData(ClipboardData(text: widget.item.address));

    if (!mounted) return;

    showFlushbar(
      context,
      message: AppLocalizations.of(context)!.copied,
    );
  }
}
