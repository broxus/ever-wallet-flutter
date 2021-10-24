import 'package:crystal/domain/blocs/biometry/biometry_password_data_bloc.dart';
import 'package:crystal/domain/blocs/key/key_export_bloc.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../domain/blocs/application_flow_bloc.dart';
import '../../../domain/blocs/biometry/biometry_info_bloc.dart';
import '../../../domain/blocs/key/keys_bloc.dart';
import '../../../injection.dart';
import '../../design/design.dart';
import '../../design/widget/crystal_bottom_sheet.dart';
import '../../router.gr.dart';
import 'biometry_modal_body.dart';
import 'change_seed_phrase_password_modal_body.dart';
import 'derive_key_modal_body.dart';
import 'export_seed_phrase_modal_body.dart';
import 'name_new_key_modal_body.dart';
import 'remove_seed_phrase_modal_body.dart';
import 'rename_key_modal_body.dart';

class SettingsPage extends StatefulWidget {
  static final _longDivider = Container(
    color: CrystalColor.divider,
    height: 1,
  );

  static final _shortDivider = Container(
    margin: const EdgeInsetsDirectional.only(start: 16),
    child: _longDivider,
  );

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Padding(
          padding: EdgeInsets.only(bottom: context.safeArea.bottom),
          child: CupertinoPageScaffold(
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
                    buildTitle(),
                    buildBody(),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildTitle() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Text(
          LocaleKeys.settings_screen_title.tr(),
          style: const TextStyle(
            fontSize: 30,
            color: CrystalColor.fontDark,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget buildBody() => Expanded(
        child: CupertinoTheme(
          data: const CupertinoThemeData(brightness: Brightness.light),
          child: CupertinoScrollbar(
            controller: scrollController,
            child: FadingEdgeScrollView.fromSingleChildScrollView(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                controller: scrollController,
                child: BlocBuilder<KeysBloc, KeysState>(
                  bloc: context.watch<KeysBloc>(),
                  builder: (context, state) => buildSettingsItemsList(
                    keys: state.keys,
                    currentKey: state.currentKey,
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget buildSettingsItemsList({
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
    KeyStoreEntry? currentKey,
  }) =>
      Column(
        children: [
          buildSection(
            title: LocaleKeys.settings_screen_sections_seeds_title.tr(),
            children: [
              if (keys.isNotEmpty)
                buildSeedsList(
                  selectedSeed: currentKey,
                  seeds: keys,
                  onAdd: () {
                    context.router.push(const NewSeedRouterRoute());
                  },
                  onSelect: (seed) {
                    context.read<KeysBloc>().add(KeysEvent.setCurrent(seed.publicKey));
                  },
                  showAddAction: true,
                ),
            ],
          ),
          buildSection(
            title: LocaleKeys.settings_screen_sections_current_seed_preferences_title.tr(),
            children: [
              buildSectionAction(
                title: LocaleKeys.settings_screen_sections_current_seed_preferences_export_seed.tr(),
                onTap: keys.isNotEmpty && currentKey != null
                    ? () async {
                        String? password;

                        final biometryInfoBloc = context.read<BiometryInfoBloc>();
                        final biometryPasswordDataBloc = getIt.get<BiometryPasswordDataBloc>();
                        final keyExportBloc = getIt.get<KeyExportBloc>();

                        if (biometryInfoBloc.state.isAvailable && biometryInfoBloc.state.isEnabled) {
                          biometryPasswordDataBloc.add(BiometryPasswordDataEvent.get(currentKey.publicKey));

                          final state = await biometryPasswordDataBloc.stream.first;

                          password = state.maybeWhen(
                            ready: (password) => password,
                            orElse: () => null,
                          );

                          if (password != null) {
                            keyExportBloc.add(KeyExportEvent.export(
                              publicKey: currentKey.publicKey,
                              password: password,
                            ));

                            final state = await keyExportBloc.stream.first;

                            state.maybeWhen(
                              success: (phrase) => context.router.navigate(SeedPhraseExportRoute(phrase: phrase)),
                              orElse: () => null,
                            );
                          } else {
                            showCrystalBottomSheet(
                              context,
                              title: ExportSeedPhraseModalBody.title,
                              body: ExportSeedPhraseModalBody(publicKey: currentKey.publicKey),
                            );
                          }

                          Future.delayed(const Duration(seconds: 1), () async {
                            biometryPasswordDataBloc.close();
                            keyExportBloc.close();
                          });
                        } else {
                          showCrystalBottomSheet(
                            context,
                            title: ExportSeedPhraseModalBody.title,
                            body: ExportSeedPhraseModalBody(publicKey: currentKey.publicKey),
                          );
                        }
                      }
                    : null,
              ),
              buildSectionAction(
                title: LocaleKeys.settings_screen_sections_current_seed_preferences_remove_seed.tr(),
                onTap: keys.isNotEmpty && currentKey != null
                    ? () {
                        showCrystalBottomSheet(
                          context,
                          title: RemoveSeedPhraseModalBody.title,
                          body: RemoveSeedPhraseModalBody(publicKey: currentKey.publicKey),
                          expand: false,
                          avoidBottomInsets: false,
                          hasTitleDivider: true,
                        );
                      }
                    : null,
              ),
              buildSectionAction(
                title: LocaleKeys.settings_screen_sections_current_seed_preferences_change_seed_password.tr(),
                onTap: keys.isNotEmpty && currentKey != null
                    ? () {
                        showCrystalBottomSheet(
                          context,
                          title: LocaleKeys.settings_screen_sections_current_seed_preferences_change_seed_password.tr(),
                          body: ChangeSeedPhrasePasswordModalBody(publicKey: currentKey.publicKey),
                        );
                      }
                    : null,
              ),
              if (currentKey != null && currentKey.isNotLegacy && currentKey.publicKey == currentKey.masterKey)
                buildSectionAction(
                  title: LocaleKeys.settings_screen_sections_current_seed_preferences_derive_key.tr(),
                  onTap: keys.isNotEmpty
                      ? () async {
                          final name = await showCrystalBottomSheet<String?>(
                            context,
                            title: NameNewKeyModalBody.title,
                            body: const NameNewKeyModalBody(),
                          );

                          if (name != null) {
                            showCrystalBottomSheet(
                              context,
                              title: DeriveKeyModalBody.title,
                              body: DeriveKeyModalBody(
                                publicKey: currentKey.publicKey,
                                name: name.isNotEmpty ? name : null,
                              ),
                            );
                          }
                        }
                      : null,
                ),
              buildSectionAction(
                title: LocaleKeys.settings_screen_sections_current_seed_preferences_rename_key.tr(),
                onTap: keys.isNotEmpty && currentKey != null
                    ? () {
                        showCrystalBottomSheet(
                          context,
                          title: LocaleKeys.rename_key_modal_title.tr(),
                          body: RenameKeyModalBody(publicKey: currentKey.publicKey),
                        );
                      }
                    : null,
              ),
            ],
          ),
          buildSection(
            title: LocaleKeys.settings_screen_sections_wallet_preferences_title.tr(),
            children: [
              BlocBuilder<BiometryInfoBloc, BiometryInfoState>(
                bloc: context.watch<BiometryInfoBloc>(),
                builder: (context, biometryInfoState) => biometryInfoState.isAvailable
                    ? buildSectionAction(
                        title: LocaleKeys.biometry_title.tr(),
                        onTap: () {
                          showCrystalBottomSheet(
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
          buildSection(
            children: [
              buildSectionAction(
                isDestructive: true,
                title: LocaleKeys.settings_screen_sections_logout_action.tr(),
                onTap: () {
                  showPlatformDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) => Theme(
                      data: ThemeData(),
                      child: PlatformAlertDialog(
                        title: Text(LocaleKeys.settings_screen_sections_logout_confirmation.tr()),
                        actions: [
                          PlatformDialogAction(
                            onPressed: Navigator.of(context).pop,
                            child: Text(LocaleKeys.actions_cancel.tr()),
                          ),
                          PlatformDialogAction(
                            onPressed: () {
                              context.read<ApplicationFlowBloc>().add(const ApplicationFlowEvent.logOut());
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
          buildAppVersion(),
        ],
      );

  Widget buildSeedsList({
    KeyStoreEntry? selectedSeed,
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> seeds,
    required Function(KeyStoreEntry) onSelect,
    required Function() onAdd,
    required bool showAddAction,
  }) {
    final children = <Widget>[];
    final divider = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(52, 0, 0, 0),
      child: SettingsPage._longDivider,
    );
    Widget? child;
    for (final seed in seeds.keys) {
      child = buildSeedItem(
        seed: seed,
        selectedSeed: selectedSeed,
        onSelect: onSelect,
      );

      children.add(child);
      child = null;
      if (seeds[seed] != null && seeds[seed]!.isNotEmpty) {
        for (final key in seeds[seed]!) {
          child = buildSeedItem(
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
      child = buildSectionActionWithIcon(
        onTap: onAdd,
        color: CrystalColor.accent,
        title: LocaleKeys.settings_screen_sections_seeds_add_seed.tr(),
        icon: const Icon(
          CupertinoIcons.add,
          size: 20,
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

  Widget buildSeedItem({
    KeyStoreEntry? selectedSeed,
    required KeyStoreEntry seed,
    required Function(KeyStoreEntry) onSelect,
    bool isChild = false,
  }) {
    Widget? child;
    final selected = seed.publicKey == selectedSeed?.publicKey;
    if (selected) {
      child = const Icon(
        CupertinoIcons.checkmark_alt,
        size: 24,
        color: CrystalColor.fontDark,
      );
    }

    return buildSectionActionWithIcon(
      onTap: () {
        if (!selected) {
          HapticFeedback.selectionClick();
          onSelect(seed);
        }
      },
      title: seed.name,
      icon: child,
      isChild: isChild,
    );
  }

  Widget buildSection({
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

    childrenWithDividers.add(SettingsPage._longDivider);

    if (children.isNotEmpty) {
      for (final child in children.sublist(0, children.length - 1)) {
        childrenWithDividers.add(child);
        childrenWithDividers.add(SettingsPage._shortDivider);
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

    childrenWithDividers.add(SettingsPage._longDivider);

    return AnimatedSize(
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

  Widget buildSectionAction({
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 44,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: onTap != null ? 1 : 0),
            duration: kThemeAnimationDuration,
            builder: (context, value, _) => Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color: color.lerp(value),
                letterSpacing: 0.25,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionActionWithIcon({
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
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        color: color ?? CrystalColor.fontDark,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildAppVersion() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final version = snapshot.data?.version;
              final buildNumber = snapshot.data?.buildNumber;

              return Text(
                'Version $version.$buildNumber',
                style: const TextStyle(
                  fontSize: 12,
                  color: CrystalColor.fontSecondaryDark,
                  letterSpacing: 0.25,
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      );
}
