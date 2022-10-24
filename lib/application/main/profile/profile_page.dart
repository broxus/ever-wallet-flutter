import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/async_value_future_provider.dart';
import 'package:ever_wallet/application/common/async_value_stream_provider.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/profile/biometry_modal_body.dart';
import 'package:ever_wallet/application/main/profile/export_seed_phrase_modal_body.dart';
import 'package:ever_wallet/application/main/profile/language_modal_body.dart';
import 'package:ever_wallet/application/main/profile/logout_modal/show_logout_modal.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/seed_phrase_export_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seeds_screen.dart';
import 'package:ever_wallet/application/main/profile/widgets/keys_builder.dart';
import 'package:ever_wallet/application/util/auth_utils.dart';
import 'package:ever_wallet/application/util/extensions/context_extensions.dart';
import 'package:ever_wallet/data/repositories/biometry_repository.dart';
import 'package:ever_wallet/data/repositories/keys_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 8),
      child: Text(
        context.localization.profile,
        style: themeStyle.styles.appbarStyle.copyWith(
          color: themeStyle.colors.primaryButtonTextColor,
        ),
      ),
    );
  }

  Widget buildBody() => SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 16),
        controller: scrollController,
        child: KeysBuilderWidget(
          builder: (keys, current) => buildSettingsItemsList(keys: keys, currentKey: current),
        ),
      );

  Widget buildSettingsItemsList({
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> keys,
    KeyStoreEntry? currentKey,
  }) {
    final localization = context.localization;

    return Column(
      children: [
        buildSection(
          title: localization.current_seed_name_of_seed.toUpperCase(),
          children: [
            buildSectionAction(
              title: localization.export_seed,
              onTap: keys.isNotEmpty && currentKey != null
                  ? () => AuthUtils.askPasswordBeforeExport(
                        context: context,
                        seed: currentKey,
                        goExport: (phrase) {
                          if (!mounted) return;
                          showEWBottomSheet<void>(
                            context,
                            title: context.localization.save_seed_phrase,
                            body: (_) => SeedPhraseExportSheet(phrase: phrase),
                          );
                        },
                        enterPassword: (seed) {
                          if (!mounted) return;

                          showEWBottomSheet<void>(
                            context,
                            title: context.localization.export_enter_password,
                            body: (_) => ExportSeedPhraseModalBody(publicKey: seed.publicKey),
                          );
                        },
                      )
                  : null,
            ),
            buildSection(
              title: localization.all_seeds.toUpperCase(),
              children: [
                if (keys.isNotEmpty)
                  buildSeedsList(
                    selectedSeed: currentKey,
                    seeds: keys,
                    onAdd: () => Navigator.of(context).push(ManageSeedsRoute()),
                    onSelect: (seed) =>
                        context.read<KeysRepository>().setCurrentKey(seed.publicKey),
                    showAddAction: true,
                    localization: localization,
                  ),
              ],
            ),
          ],
        ),
        buildSection(
          title: localization.preferences.toUpperCase(),
          children: [
            AsyncValueStreamProvider<bool>(
              create: (context) => context.read<BiometryRepository>().availabilityStream,
              builder: (context, child) {
                final isAvailable = context.watch<AsyncValue<bool>>().maybeWhen(
                      ready: (value) => value,
                      orElse: () => false,
                    );

                return isAvailable
                    ? buildSectionAction(
                        title: localization.biometry,
                        onTap: () {
                          showEWBottomSheet<void>(
                            context,
                            title: localization.biometry,
                            body: (_) => const BiometryModalBody(),
                          );
                        },
                      )
                    : const SizedBox();
              },
            ),
            buildSectionAction(
              title: localization.language,
              onTap: () {
                showEWBottomSheet<void>(
                  context,
                  title: localization.language,
                  body: (_) => const LanguageModalBody(),
                );
              },
            ),
          ],
        ),
        buildSectionAction(
          color: context.themeStyle.colors.errorTextColor,
          title: localization.logout,
          onTap: () => showLogoutDialog(context: context),
        ),
        buildAppVersion(),
      ],
    );
  }

  Widget buildSeedsList({
    KeyStoreEntry? selectedSeed,
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> seeds,
    required void Function(KeyStoreEntry) onSelect,
    required void Function() onAdd,
    required bool showAddAction,
    required AppLocalizations localization,
  }) {
    final children = <Widget>[];
    for (final seed in seeds.keys) {
      children.add(
        buildSeedItem(
          seed: seed,
          selectedSeed: selectedSeed,
          onSelect: seed == selectedSeed ? null : onSelect,
        ),
      );
      if (seeds[seed] != null && seeds[seed]!.isNotEmpty) {
        for (final key in seeds[seed]!) {
          children.add(
            buildSeedItem(
              seed: key,
              selectedSeed: selectedSeed,
              onSelect: key == selectedSeed ? null : onSelect,
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
          title: localization.manage_seeds_accounts,
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
    required void Function(KeyStoreEntry)? onSelect,
    bool isChild = false,
  }) {
    IconData? icon;
    final selected = seed.publicKey == selectedSeed?.publicKey;
    if (selected) {
      icon = CupertinoIcons.checkmark_alt;
    }

    return buildSectionActionWithIcon(
      onTap: onSelect == null
          ? null
          : () {
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
        child: AsyncValueFutureProvider<PackageInfo>(
          create: (context) => PackageInfo.fromPlatform(),
          builder: (context, child) => context.watch<AsyncValue<PackageInfo>>().maybeWhen(
                ready: (value) {
                  final version = value.version;
                  final buildNumber = value.buildNumber;

                  return Text(
                    context.localization.version_v_b(version, buildNumber),
                    style: const TextStyle(
                      fontSize: 12,
                      color: CrystalColor.fontSecondaryDark,
                      letterSpacing: 0.25,
                    ),
                  );
                },
                orElse: () => const SizedBox(),
              ),
        ),
      );
}
