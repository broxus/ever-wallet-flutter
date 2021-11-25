import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import '../../../../design/theme.dart';
import '../../../../design/widgets/account_icon.dart';

class BrowserAppBar extends StatefulWidget {
  final AssetsList? currentAccount;
  final TextEditingController urlController;
  final ValueNotifier<bool> backButtonEnabledNotifier;
  final ValueNotifier<bool> forwardButtonEnabledNotifier;
  final ValueNotifier<bool> addressFieldFocusedNotifier;
  final ValueNotifier<int> progressNotifier;
  final VoidCallback onGoBack;
  final VoidCallback onGoForward;
  final VoidCallback onGoHome;
  final VoidCallback onAccountButtonTapped;
  final VoidCallback onRefreshButtonTapped;
  final VoidCallback onShareButtonTapped;
  final void Function(String url) onUrlEntered;

  const BrowserAppBar({
    Key? key,
    this.currentAccount,
    required this.urlController,
    required this.backButtonEnabledNotifier,
    required this.forwardButtonEnabledNotifier,
    required this.addressFieldFocusedNotifier,
    required this.progressNotifier,
    required this.onGoBack,
    required this.onGoForward,
    required this.onGoHome,
    required this.onAccountButtonTapped,
    required this.onRefreshButtonTapped,
    required this.onShareButtonTapped,
    required this.onUrlEntered,
  }) : super(key: key);

  @override
  _BrowserAppBarState createState() => _BrowserAppBarState();
}

class _BrowserAppBarState extends State<BrowserAppBar> {
  @override
  void initState() {
    super.initState();
    widget.addressFieldFocusedNotifier.addListener(selectTextOnFocus);
  }

  @override
  void dispose() {
    widget.addressFieldFocusedNotifier.removeListener(selectTextOnFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
        children: [
          buildNavigationButtons(),
          Expanded(
            child: buildAddressField(),
          ),
          buildHomeButton(),
          buildPopupAccountMenu(),
        ],
      );

  Widget buildNavigationButtons() => ValueListenableBuilder<bool>(
        valueListenable: widget.addressFieldFocusedNotifier,
        builder: (context, value, child) => value
            ? const SizedBox(width: 24)
            : Wrap(
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: widget.backButtonEnabledNotifier,
                    builder: (context, value, child) => CupertinoButton(
                      onPressed: value ? widget.onGoBack : null,
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.back,
                        color: value ? CrystalColor.accent : CrystalColor.hintColor,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: widget.forwardButtonEnabledNotifier,
                    builder: (context, value, child) => CupertinoButton(
                      onPressed: value ? widget.onGoForward : null,
                      padding: EdgeInsets.zero,
                      child: Icon(
                        CupertinoIcons.forward,
                        color: value ? CrystalColor.accent : CrystalColor.hintColor,
                      ),
                    ),
                  ),
                ],
              ),
      );

  Widget buildAddressField() => Theme(
        data: ThemeData(),
        child: CupertinoTextField(
          controller: widget.urlController,
          onSubmitted: (value) => widget.onUrlEntered(value.trim()),
          keyboardType: TextInputType.url,
          autocorrect: false,
          suffix: ValueListenableBuilder<TextEditingValue>(
            valueListenable: widget.urlController,
            builder: (context, textEditingValue, child) => ValueListenableBuilder<bool>(
              valueListenable: widget.addressFieldFocusedNotifier,
              builder: (context, value, child) => ValueListenableBuilder<int>(
                valueListenable: widget.progressNotifier,
                builder: (context, progressValue, child) => value && textEditingValue.text.isNotEmpty
                    ? GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: widget.urlController.clear,
                        child: Container(
                          width: 24,
                          height: 24,
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(right: 8),
                          child: const Icon(
                            CupertinoIcons.clear_thick_circled,
                            size: 18,
                            color: CrystalColor.hintColor,
                          ),
                        ),
                      )
                    : progressValue != 100
                        ? Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(right: 8),
                            child: PlatformCircularProgressIndicator(
                              material: (context, platform) => MaterialProgressIndicatorData(strokeWidth: 2),
                            ),
                          )
                        : const SizedBox(),
              ),
            ),
          ),
        ),
      );

  Widget buildHomeButton() => ValueListenableBuilder<bool>(
        valueListenable: widget.addressFieldFocusedNotifier,
        builder: (context, value, child) => value
            ? const SizedBox.shrink()
            : CupertinoButton(
                onPressed: widget.onGoHome,
                padding: EdgeInsets.zero,
                child: const Icon(
                  CupertinoIcons.home,
                  color: CrystalColor.accent,
                ),
              ),
      );

  Widget buildPopupAccountMenu() => Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          dividerTheme: const DividerThemeData(color: Colors.grey),
        ),
        child: PopupMenuButton<int>(
          color: CrystalColor.grayBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          icon: const Icon(
            CupertinoIcons.ellipsis,
            color: CrystalColor.accent,
          ),
          itemBuilder: (context) => [
            if (widget.currentAccount != null) ...[
              buildPopupAccountMenuItem(value: 0, currentAccount: widget.currentAccount!),
              const PopupMenuDivider(),
            ],
            buildPopupMenuItem(
              value: 1,
              text: LocaleKeys.browser_reload.tr(),
            ),
            const PopupMenuDivider(),
            buildPopupMenuItem(
              value: 2,
              text: LocaleKeys.browser_share.tr(),
            ),
          ],
          onSelected: onItemSelected,
        ),
      );

  PopupMenuEntry<int> buildPopupAccountMenuItem({
    required int value,
    required AssetsList currentAccount,
  }) =>
      PopupMenuItem<int>(
        value: 0,
        child: Row(
          children: [
            SizedBox.square(
              dimension: 24,
              child: AccountIcon(address: currentAccount.address),
            ),
            const SizedBox(
              width: 8,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentAccount.name,
                  style: const TextStyle(color: Colors.black),
                ),
                Text(
                  widget.currentAccount!.address.ellipseAddress(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Spacer(),
            const SizedBox(
              height: 20,
              width: 20,
              child: Center(
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: CrystalColor.icon,
                  size: 14,
                ),
              ),
            ),
          ],
        ),
      );

  PopupMenuEntry<int> buildPopupMenuItem({
    required int value,
    required String text,
  }) =>
      PopupMenuItem<int>(
        value: value,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
          ),
        ),
      );

  void onItemSelected(int item) {
    switch (item) {
      case 0:
        widget.onAccountButtonTapped();
        break;
      case 1:
        widget.onRefreshButtonTapped();
        break;
      case 2:
        widget.onShareButtonTapped();
        break;
    }
  }

  void selectTextOnFocus() {
    if (widget.addressFieldFocusedNotifier.value == true) {
      widget.urlController.value = widget.urlController.value.copyWith(
        selection: TextSelection(
          baseOffset: 0,
          extentOffset: widget.urlController.text.length,
        ),
      );
    }
  }
}