import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../domain/blocs/account/account_info_bloc.dart';
import '../../../../../../domain/blocs/account/account_renaming_bloc.dart';
import '../../../../../../domain/utils/explorer.dart';
import '../../../../../../injection.dart';
import '../../../../../design/design.dart';
import '../../../../../design/widgets/crystal_title.dart';
import '../../../../../design/widgets/custom_close_button.dart';
import '../../../../../design/widgets/custom_outlined_button.dart';
import '../../../../../design/widgets/custom_text_form_field.dart';
import '../../../../../design/widgets/text_field_clear_button.dart';
import '../../../../../design/widgets/text_suffix_icon_button.dart';

class PreferencesModalBody extends StatefulWidget {
  final String address;

  const PreferencesModalBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  @override
  State<PreferencesModalBody> createState() => _PreferencesModalBodyState();
}

class _PreferencesModalBodyState extends State<PreferencesModalBody> {
  final controller = TextEditingController();
  final renamingBloc = getIt.get<AccountRenamingBloc>();
  final infoBloc = getIt.get<AccountInfoBloc>();

  @override
  void initState() {
    super.initState();
    infoBloc.add(AccountInfoEvent.load(widget.address));
  }

  @override
  void didUpdateWidget(covariant PreferencesModalBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.address != widget.address) {
      infoBloc.add(AccountInfoEvent.load(widget.address));
    }
  }

  @override
  Widget build(BuildContext context) => BlocListener<AccountInfoBloc, AssetsList?>(
        bloc: infoBloc,
        listener: (context, state) {
          if (state != null) {
            controller.text = state.name;
            controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
          }
        },
        child: BlocListener<AccountRenamingBloc, AccountRenamingState>(
          bloc: renamingBloc,
          listener: (context, state) => state.maybeWhen(
            success: () => showCrystalFlushbar(
              context,
              message: LocaleKeys.preferences_modal_message_renamed.tr(),
            ),
            error: (exception) => showErrorCrystalFlushbar(
              context,
              message: exception.toString(),
            ),
            orElse: () => null,
          ),
          child: Material(
            color: Colors.white,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: title(),
                          ),
                          const CustomCloseButton(),
                        ],
                      ),
                      const SizedBox(height: 16),
                      field(),
                      const SizedBox(height: 16),
                      card(),
                      const SizedBox(height: 16),
                      explorerButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget card() => AddressCard(address: widget.address);

  Widget title() => const CrystalTitle(
        text: 'Preferences',
      );

  Widget field() => CustomTextFormField(
        name: 'name',
        controller: controller,
        autocorrect: false,
        enableSuggestions: false,
        hintText: 'Name...',
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFieldClearButton(
              controller: controller,
            ),
            SuffixIconButton(
              onPressed: () => renamingBloc.add(
                AccountRenamingEvent.rename(
                  address: widget.address,
                  name: controller.text,
                ),
              ),
              icon: const Icon(
                Icons.save,
                color: CrystalColor.accent,
              ),
            ),
          ],
        ),
      );

  Widget explorerButton() => CustomOutlinedButton(
        onPressed: () => launch(getAccountExplorerLink(widget.address)),
        text: 'See in the explorer',
      );
}
