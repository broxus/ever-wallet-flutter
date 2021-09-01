import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/blocs/application_flow_bloc.dart';
import '../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../domain/blocs/key/keys_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';
import '../../design/widget/crystal_bottom_sheet.dart';
import 'biometry_modal_body.dart';
import 'change_seed_phrase_password_modal_body.dart';
import 'derive_key_modal_body.dart';
import 'export_seed_phrase_modal_body.dart';
import 'name_new_key_modal_body.dart';
import 'remove_seed_phrase_modal_body.dart';
import 'rename_key_modal_body.dart';

class SettingsScreen extends StatefulWidget {
  static final _longDivider = Container(
    color: CrystalColor.divider,
    height: 1,
  );

  static final _shortDivider = Container(
    margin: const EdgeInsetsDirectional.only(start: 16.0),
    child: _longDivider,
  );

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  final bloc = getIt.get<KeysBloc>();
  final scrollController = ScrollController();

  @override
  void dispose() {
    bloc.close();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Padding(
          padding: EdgeInsets.only(bottom: context.safeArea.bottom),
          child: buildChild(),
        ),
      );

  Widget buildChild() => CupertinoPageScaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CrystalColor.iosBackground,
        child: SafeArea(
          bottom: false,
          child: MediaQuery.removePadding(
            context: context,
            removeBottom: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Text(
                    LocaleKeys.settings_screen_title.tr(),
                    style: const TextStyle(
                      fontSize: 30,
                      color: CrystalColor.fontDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(brightness: Brightness.light),
                    child: CupertinoScrollbar(
                      controller: scrollController,
                      child: FadingEdgeScrollView.fromSingleChildScrollView(
                        gradientFractionOnEnd: 0.05,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          controller: scrollController,
                          child: BlocBuilder<KeysBloc, KeysState>(
                            bloc: bloc,
                            builder: (context, state) => state.maybeWhen(
                              ready: (keys, currentKey) => Column(
                                children: [
                                  _section(
                                    title: LocaleKeys.settings_screen_sections_seeds_title.tr(),
                                    children: [
                                      if (keys.isNotEmpty)
                                        _seedsList(
                                          selectedSeed: currentKey,
                                          seeds: keys,
                                          onAdd: () {
                                            context.router.push(const NewSeedFlowRoute());
                                          },
                                          onSelect: (seed) {
                                            bloc.add(KeysEvent.setCurrentKey(seed));
                                          },
                                          showAddAction: true,
                                        ),
                                    ],
                                  ),
                                  _section(
                                    title: LocaleKeys.settings_screen_sections_current_seed_preferences_title.tr(
                                      args: [if (currentKey != null) currentKey.value.publicKey else 'Seed'],
                                    ),
                                    children: [
                                      _sectionAction(
                                        title: LocaleKeys.settings_screen_sections_current_seed_preferences_export_seed
                                            .tr(),
                                        onTap: keys.isNotEmpty && currentKey != null
                                            ? () {
                                                CrystalBottomSheet.show(
                                                  context,
                                                  title: ExportSeedPhraseModalBody.title,
                                                  body: ExportSeedPhraseModalBody(keySubject: currentKey),
                                                );
                                              }
                                            : null,
                                      ),
                                      _sectionAction(
                                        title: LocaleKeys.settings_screen_sections_current_seed_preferences_remove_seed
                                            .tr(),
                                        onTap: keys.isNotEmpty && currentKey != null
                                            ? () {
                                                CrystalBottomSheet.show(
                                                  context,
                                                  title: RemoveSeedPhraseModalBody.title,
                                                  body: RemoveSeedPhraseModalBody(keySubject: currentKey),
                                                  expand: false,
                                                  avoidBottomInsets: false,
                                                  hasTitleDivider: true,
                                                );
                                              }
                                            : null,
                                      ),
                                      _sectionAction(
                                        title: LocaleKeys
                                            .settings_screen_sections_current_seed_preferences_change_seed_password
                                            .tr(),
                                        onTap: keys.isNotEmpty && currentKey != null
                                            ? () {
                                                CrystalBottomSheet.show(
                                                  context,
                                                  title: LocaleKeys
                                                      .settings_screen_sections_current_seed_preferences_change_seed_password
                                                      .tr(),
                                                  body: ChangeSeedPhrasePasswordModalBody(keySubject: currentKey),
                                                );
                                              }
                                            : null,
                                      ),
                                      if (currentKey != null &&
                                          currentKey.value.isNotLegacy &&
                                          currentKey.value.publicKey == currentKey.value.masterKey)
                                        _sectionAction(
                                          title: LocaleKeys.settings_screen_sections_current_seed_preferences_derive_key
                                              .tr(),
                                          onTap: keys.isNotEmpty && currentKey != null
                                              ? () async {
                                                  final name = await CrystalBottomSheet.show<String>(
                                                    context,
                                                    title: NameNewKeyModalBody.title,
                                                    body: const NameNewKeyModalBody(),
                                                  );

                                                  if (name != null) {
                                                    CrystalBottomSheet.show(
                                                      context,
                                                      title: DeriveKeyModalBody.title,
                                                      body: DeriveKeyModalBody(
                                                        keySubject: currentKey,
                                                        name: name,
                                                      ),
                                                    );
                                                  }
                                                }
                                              : null,
                                        ),
                                      _sectionAction(
                                        title: LocaleKeys.settings_screen_sections_current_seed_preferences_rename_key
                                            .tr(),
                                        onTap: keys.isNotEmpty && currentKey != null
                                            ? () {
                                                CrystalBottomSheet.show(
                                                  context,
                                                  title: LocaleKeys.rename_key_modal_title.tr(),
                                                  body: RenameKeyModalBody(keySubject: currentKey),
                                                );
                                              }
                                            : null,
                                      ),
                                    ],
                                  ),
                                  _section(
                                    title: LocaleKeys.settings_screen_sections_wallet_preferences_title.tr(),
                                    children: [
                                      BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
                                        bloc: context.watch<BiometryInfoBloc>(),
                                        builder: (context, biometryInfoState) => biometryInfoState.isAvailable
                                            ? _sectionAction(
                                                title: LocaleKeys.biometry_title.tr(),
                                                onTap: () {
                                                  CrystalBottomSheet.show(
                                                    context,
                                                    title: LocaleKeys.biometry_title.tr(),
                                                    body: const BiometryModalBody(),
                                                  );
                                                },
                                              )
                                            : const SizedBox(),
                                      ),
                                    ],
                                  ),
                                  _section(
                                    children: [
                                      _sectionAction(
                                        isDestructive: true,
                                        title: LocaleKeys.settings_screen_sections_logout_action.tr(),
                                        onTap: () {
                                          showPlatformDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (context) => Theme(
                                              data: ThemeData(),
                                              child: PlatformAlertDialog(
                                                title:
                                                    Text(LocaleKeys.settings_screen_sections_logout_confirmation.tr()),
                                                actions: [
                                                  PlatformDialogAction(
                                                    onPressed: Navigator.of(context).pop,
                                                    child: Text(LocaleKeys.actions_cancel.tr()),
                                                  ),
                                                  PlatformDialogAction(
                                                    onPressed: () {
                                                      context
                                                          .read<ApplicationFlowBloc>()
                                                          .add(const ApplicationFlowEvent.logOut());
                                                      Navigator.of(context).pop();
                                                    },
                                                    cupertino: (_, __) => CupertinoDialogActionData(
                                                      isDestructiveAction: true,
                                                    ),
                                                    material: (_, __) => MaterialDialogActionData(
                                                      style: TextButton.styleFrom(
                                                        primary: CrystalColor.error,
                                                      ),
                                                    ),
                                                    child: Text(LocaleKeys.settings_screen_sections_logout_action.tr()),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              orElse: () => const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );

  Widget _seedsList({
    required KeySubject? selectedSeed,
    required Map<KeySubject, List<KeySubject>?> seeds,
    required Function(KeySubject) onSelect,
    required Function() onAdd,
    required bool showAddAction,
  }) {
    final children = <Widget>[];
    final divider = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(52, 0, 0, 0),
      child: SettingsScreen._longDivider,
    );
    Widget? child;
    for (final seed in seeds.keys) {
      child = _seedItem(
        seed: seed,
        selectedSeed: selectedSeed,
        onSelect: onSelect,
      );

      children.add(child);
      child = null;
      if (seeds[seed] != null && seeds[seed]!.isNotEmpty) {
        for (final key in seeds[seed]!) {
          child = _seedItem(
            seed: key,
            selectedSeed: selectedSeed,
            onSelect: onSelect,
            isChild: true,
          );

          children.add(child);

          child = null;
        }
      }
      children.add(divider);
    }

    if (showAddAction) {
      child = _sectionActionWithIcon(
        onTap: onAdd,
        color: CrystalColor.accent,
        title: LocaleKeys.settings_screen_sections_seeds_add_seed.tr(),
        icon: const Icon(
          CupertinoIcons.add,
          size: 20.0,
          color: CrystalColor.accent,
        ),
      );

      children.add(child);
    } else {
      children.removeLast();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _seedItem({
    required KeySubject? selectedSeed,
    required KeySubject seed,
    required Function(KeySubject) onSelect,
    bool isChild = false,
  }) {
    Widget? child;
    final selected = seed == selectedSeed;
    if (selected) {
      child = const Icon(
        CupertinoIcons.checkmark_alt,
        size: 24.0,
        color: CrystalColor.fontDark,
      );
    }

    return _sectionActionWithIcon(
      onTap: () {
        if (!selected) {
          HapticFeedback.selectionClick();
          onSelect(seed);
        }
      },
      title: seed.value.name,
      icon: child,
      isChild: isChild,
    );
  }

  Widget _section({
    String? title,
    required List<Widget> children,
  }) {
    Widget? titleWidget;

    if (title != null) {
      titleWidget = Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: CrystalColor.fontSecondaryDark,
        ),
      );
    }

    titleWidget = Container(
      height: 20,
      margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 20, 8),
      child: titleWidget,
    );

    final childrenWithDividers = <Widget>[];

    childrenWithDividers.add(SettingsScreen._longDivider);

    if (children.isNotEmpty) {
      for (final child in children.sublist(0, children.length - 1)) {
        childrenWithDividers.add(child);
        childrenWithDividers.add(SettingsScreen._shortDivider);
      }
      childrenWithDividers.add(children.last);
    } else {
      childrenWithDividers.add(
        Shimmer.fromColors(
          baseColor: CrystalColor.shimmerBackground,
          highlightColor: CrystalColor.iosBackground.withOpacity(0.7),
          child: Container(
            height: 48,
            color: Colors.white,
          ),
        ),
      );
    }

    childrenWithDividers.add(SettingsScreen._longDivider);

    return AnimatedSize(
      vsync: this,
      duration: kThemeAnimationDuration,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleWidget,
          ColoredBox(
            color: CrystalColor.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: childrenWithDividers,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionAction({
    required String title,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final color = ColorTween(
      begin: CrystalColor.fontSecondaryDark,
      end: isDestructive ? CrystalColor.error : CrystalColor.fontDark,
    );

    return Material(
      type: MaterialType.transparency,
      child: CrystalInkWell(
        onTap: onTap,
        highlightColor: isDestructive ? CrystalColor.error : null,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          height: 44,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: onTap != null ? 1.0 : 0.0),
            duration: kThemeAnimationDuration,
            builder: (context, value, _) => Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                color: color.lerp(value),
                letterSpacing: 0.25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionActionWithIcon({
    required String title,
    Color? color,
    Widget? icon,
    VoidCallback? onTap,
    bool isChild = false,
  }) =>
      Material(
        type: MaterialType.transparency,
        child: CrystalInkWell(
          onTap: onTap,
          highlightColor: color,
          child: Container(
            color: isChild ? CrystalColor.divider.withOpacity(0.3) : Colors.white,
            padding: EdgeInsets.only(left: isChild ? 24 : 0),
            height: 44,
            child: Row(
              children: [
                Container(
                  alignment: Alignment.center,
                  width: 52,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 100),
                    child: icon ?? const SizedBox(),
                  ),
                ),
                Expanded(
                  child: Text(
                    title.length > 8 ? '${title.substring(0, 4)}...${title.substring(title.length - 4)}' : title,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: color ?? CrystalColor.fontDark,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
