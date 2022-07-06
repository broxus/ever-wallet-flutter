import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../../injection.dart';
import '../../../../../data/repositories/keys_repository.dart';
import '../../../../../injection.dart';
import '../../../../data/repositories/keys_repository.dart';
import '../../../../providers/biometry/biometry_availability_provider.dart';
import '../../../../providers/key/current_key_provider.dart';
import '../../../../providers/key/keys_provider.dart';
import '../../common/general/default_divider.dart';
import '../../common/theme.dart';
import '../../common/widgets/ew_bottom_sheet.dart';
import '../../util/auth_utils.dart';
import '../../util/extensions/context_extensions.dart';
import 'biometry_modal_body.dart';
import 'export_seed_phrase_modal_body.dart';
import 'language_modal_body.dart';
import 'logout_modal/show_logout_modal.dart';
import 'manage_seeds_screen.dart';
import 'seed_phrase_export_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final divider = const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: DefaultDivider(),
  );
  final scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildTitle(),
              Expanded(child: buildBody()),
            ],
          ),
        ),
      );

  Widget buildTitle() {
    final themeStyle = context.themeStyle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 8),
      child: Text(
        context.localization.profile,
        style: themeStyle.styles.appbarStyle.copyWith(
          color: themeStyle.colors.primaryButtonTextColor,
        ),
      ),
    );
  }

  Widget buildBody() => FadingEdgeScrollView.fromSingleChildScrollView(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 16),
          controller: scrollController,
          child: Consumer(
            builder: (context, ref, child) {
              final keys = ref.watch(keysProvider).asData?.value ?? {};
              final currentKey = ref.watch(currentKeyProvider).asData?.value;

              return buildSettingsItemsList(keys: keys, currentKey: currentKey);
            },
          ),
        ),
      );

  Widget buildSettingsItemsList({
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
    KeyStoreEntry? currentKey,
  }) =>
      Consumer(
        builder: (context, ref, child) => Column(
          children: [
            buildSection(
              // TODO: replace text
              title: 'Current seed (name of seed)'.toUpperCase(),
              // title: AppLocalizations.of(context)!.current_seed_preferences,
              children: [
                buildSectionAction(
                  title: AppLocalizations.of(context)!.export_seed,
                  onTap: keys.isNotEmpty && currentKey != null
                      ? () => AuthUtils.askPasswordBeforeExport(
                            ref: ref,
                            context: context,
                            seed: currentKey,
                            goExport: (phrase) {
                              if (!mounted) return;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => SeedPhraseExportPage(phrase: phrase),
                                ),
                              );
                            },
                            enterPassword: (seed) {
                              if (!mounted) return;

                              showEWBottomSheet<void>(
                                context,
                                title: context.localization.export_enter_password,
                                body: ExportSeedPhraseModalBody(publicKey: seed.publicKey),
                              );
                            },
                          )
                      : null,
                ),
                buildSection(
                  // TODO: replace text
                  title: 'All seeds'.toUpperCase(),
                  // title: context.localization.seeds,
                  children: [
                    if (keys.isNotEmpty)
                      buildSeedsList(
                        selectedSeed: currentKey,
                        seeds: keys,
                        onAdd: () => Navigator.of(context).push(ManageSeedsRoute()),
                        onSelect: (seed) => getIt.get<KeysRepository>().setCurrentKey(seed),
                        showAddAction: true,
                      ),
                  ],
                ),
                // if (currentKey != null && currentKey.isNotLegacy && currentKey.isMaster)
                // buildSectionAction(
                //   title: AppLocalizations.of(context)!.derive_key,
                //   onTap: keys.isNotEmpty
                //       ? () async {
                //           final name = await showCrystalBottomSheet<String?>(
                //             context,
                //             title: NameNewKeyModalBody.title(context),
                //             body: const NameNewKeyModalBody(),
                //           );
                //
                //           await Future<void>.delayed(const Duration(seconds: 1));
                //
                //           if (name != null) {
                //             if (!mounted) return;
                //
                //             final isEnabled = await ref.read(biometryStatusProvider.future);
                //             final isAvailable =
                //                 await ref.read(biometryAvailabilityProvider.future);
                //
                //             if (isAvailable && isEnabled) {
                //               try {
                //                 final password =
                //                     await getIt.get<BiometryRepository>().getKeyPassword(
                //                           localizedReason:
                //                               AppLocalizations.of(context)!.authentication_reason,
                //                           publicKey: currentKey.publicKey,
                //                         );
                //
                //                 await getIt.get<KeysRepository>().deriveKey(
                //                       name: name.isNotEmpty ? name : null,
                //                       publicKey: currentKey.publicKey,
                //                       password: password,
                //                     );
                //               } catch (err) {
                //                 if (!mounted) return;
                //
                //                 showCrystalBottomSheet<void>(
                //                   context,
                //                   title: DeriveKeyModalBody.title(context),
                //                   body: DeriveKeyModalBody(
                //                     publicKey: currentKey.publicKey,
                //                     name: name.isNotEmpty ? name : null,
                //                   ),
                //                 );
                //               }
                //             } else {
                //               if (!mounted) return;
                //
                //               showCrystalBottomSheet<void>(
                //                 context,
                //                 title: DeriveKeyModalBody.title(context),
                //                 body: DeriveKeyModalBody(
                //                   publicKey: currentKey.publicKey,
                //                   name: name.isNotEmpty ? name : null,
                //                 ),
                //               );
                //             }
                //           }
                //         }
                //       : null,
                // ),
              ],
            ),
            buildSection(
              // TODO: replace text
              title: 'Preferences'.toUpperCase(),
              // title: context.localization.wallet_preferences,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final isAvailable =
                        ref.watch(biometryAvailabilityProvider).asData?.value ?? false;

                    return isAvailable
                        ? buildSectionAction(
                            title: AppLocalizations.of(context)!.biometry,
                            onTap: () {
                              showEWBottomSheet<void>(
                                context,
                                title: AppLocalizations.of(context)!.biometry,
                                body: const BiometryModalBody(),
                              );
                            },
                          )
                        : const SizedBox();
                  },
                ),
                buildSectionAction(
                  title: AppLocalizations.of(context)!.language,
                  onTap: () {
                    showEWBottomSheet<void>(
                      context,
                      title: AppLocalizations.of(context)!.language,
                      body: const LanguageModalBody(),
                    );
                  },
                ),
              ],
            ),
            buildSectionAction(
              color: CrystalColor.error,
              title: AppLocalizations.of(context)!.logout,
              onTap: () => showLogoutDialog(context: context),
            ),
            buildAppVersion(),
          ],
        ),
      );

  Widget buildSeedsList({
    KeyStoreEntry? selectedSeed,
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> seeds,
    required void Function(KeyStoreEntry) onSelect,
    required void Function() onAdd,
    required bool showAddAction,
  }) {
    final children = <Widget>[];
    for (final seed in seeds.keys) {
      children.add(
        buildSeedItem(
          seed: seed,
          selectedSeed: selectedSeed,
          onSelect: onSelect,
        ),
      );
      if (seeds[seed] != null && seeds[seed]!.isNotEmpty) {
        for (final key in seeds[seed]!) {
          children.add(
            buildSeedItem(
              seed: key,
              selectedSeed: selectedSeed,
              onSelect: onSelect,
              isChild: true,
            ),
          );
        }
      }
    }

    if (showAddAction) {
      children.add(
        buildSectionAction(
          onTap: onAdd,
          // TODO: replace text
          title: 'Manage seeds & accounts',
          // title: AppLocalizations.of(context)!.add_seed,
        ),
      );
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
    required void Function(KeyStoreEntry) onSelect,
    bool isChild = false,
  }) {
    IconData? icon;
    final selected = seed.publicKey == selectedSeed?.publicKey;
    if (selected) {
      icon = CupertinoIcons.checkmark_alt;
    }

    return buildSectionActionWithIcon(
      onTap: () {
        if (!selected) {
          HapticFeedback.selectionClick();
          onSelect(seed);
        }
      },
      title: seed.name,
      icon: icon,
      isChild: isChild,
    );
  }

  Widget buildSection({
    String? title,
    required List<Widget> children,
  }) {
    Widget? titleWidget;

    if (title != null) {
      titleWidget = Text(title, style: context.themeStyle.styles.sectionCaption);
    }

    titleWidget = Container(
      height: 20,
      margin: const EdgeInsetsDirectional.fromSTEB(16, 16, 20, 8),
      child: titleWidget,
    );

    return AnimatedSize(
      duration: kThemeAnimationDuration,
      alignment: Alignment.topCenter,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          titleWidget,
          if (title != null) divider,
          ColoredBox(
            color: CrystalColor.primary,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children.isNotEmpty
                  ? children
                  : [
                      Shimmer.fromColors(
                        baseColor: CrystalColor.shimmerBackground,
                        highlightColor: CrystalColor.iosBackground.withOpacity(0.7),
                        child: Container(
                          height: 48,
                          color: Colors.white,
                        ),
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionAction({
    required String title,
    VoidCallback? onTap,
    Color? color,
  }) {
    final themeStyle = context.themeStyle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 44,
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: onTap != null ? 1 : 0),
            duration: kThemeAnimationDuration,
            builder: (context, value, _) => Text(
              title,
              maxLines: 1,
              style: context.themeStyle.styles.basicStyle.copyWith(
                color: color ?? themeStyle.colors.primaryButtonTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSectionActionWithIcon({
    required String title,
    IconData? icon,
    VoidCallback? onTap,
    bool isChild = false,
  }) {
    final themeStyle = context.themeStyle;

    return Material(
      color: isChild ? CrystalColor.divider.withOpacity(0.3) : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.only(left: isChild ? 24 : 0),
          height: 44,
          child: Row(
            children: [
              Container(
                alignment: Alignment.center,
                width: 52,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  child: icon == null
                      ? const SizedBox()
                      : Icon(icon, color: themeStyle.colors.primaryButtonTextColor, size: 20),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.themeStyle.styles.basicStyle.copyWith(
                      color: themeStyle.colors.primaryButtonTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildAppVersion() => Padding(
        padding: const EdgeInsets.only(top: 16),
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final version = snapshot.data?.version;
              final buildNumber = snapshot.data?.buildNumber;

              return Text(
                context.localization.version_v_b('$version', '$buildNumber'),
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
