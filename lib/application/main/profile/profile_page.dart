import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/general/default_divider.dart';
import 'package:ever_wallet/application/common/general/ew_bottom_sheet.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/main/profile/biometry_modal_body.dart';
import 'package:ever_wallet/application/main/profile/derive_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/export_seed_phrase_modal_body.dart';
import 'package:ever_wallet/application/main/profile/language_modal_body.dart';
import 'package:ever_wallet/application/main/profile/logout_modal/show_logout_modal.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seed_actions/seed_phrase_export_sheet.dart';
import 'package:ever_wallet/application/main/profile/manage_seed/manage_seeds_screen.dart';
import 'package:ever_wallet/application/main/profile/name_new_key_modal_body.dart';
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
  const ProfilePage({Key? key}) : super(key: key);

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
          // TODO: replace text
          title: 'Current seed (name of seed)'.toUpperCase(),
          // title: AppLocalizations.of(context)!.current_seed_preferences,
          children: [
            if (currentKey != null && currentKey.isNotLegacy && currentKey.isMaster)
              buildSectionAction(
                title: localization.derive_key,
                onTap: keys.isNotEmpty
                    ? () async {
                        final name = await showEWBottomSheet<String?>(
                          context,
                          title: localization.name_new_key,
                          body: const NameNewKeyModalBody(),
                        );

                        await Future<void>.delayed(const Duration(seconds: 1));

                        if (name != null) {
                          if (!mounted) return;

                          final isEnabled = context.read<BiometryRepository>().status;
                          final isAvailable = context.read<BiometryRepository>().availability;

                          if (isAvailable && isEnabled) {
                            try {
                              final password =
                                  await context.read<BiometryRepository>().getKeyPassword(
                                        localizedReason:
                                            AppLocalizations.of(context)!.authentication_reason,
                                        publicKey: currentKey.publicKey,
                                      );

                              if (!mounted) return;

                              await context.read<KeysRepository>().deriveKey(
                                    name: name.isNotEmpty ? name : null,
                                    publicKey: currentKey.publicKey,
                                    password: password,
                                  );
                            } catch (err) {
                              if (!mounted) return;

                              showEWBottomSheet<void>(
                                context,
                                title: localization.derive_enter_password,
                                body: DeriveKeyModalBody(
                                  publicKey: currentKey.publicKey,
                                  name: name.isNotEmpty ? name : null,
                                ),
                              );
                            }
                          } else {
                            if (!mounted) return;

                            showEWBottomSheet<void>(
                              context,
                              title: localization.derive_enter_password,
                              body: DeriveKeyModalBody(
                                publicKey: currentKey.publicKey,
                                name: name.isNotEmpty ? name : null,
                              ),
                            );
                          }
                        }
                      }
                    : null,
              ),
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
                            body: SeedPhraseExportSheet(phrase: phrase),
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
                    onSelect: (seed) => context.read<KeysRepository>().setCurrentKey(seed),
                    showAddAction: true,
                  ),
              ],
            ),
          ],
        ),
        buildSection(
          // TODO: replace text
          title: 'Preferences'.toUpperCase(),
          // title: context.localization.wallet_preferences,
          children: [
            StreamProvider<AsyncValue<bool>>(
              create: (context) => context
                  .read<BiometryRepository>()
                  .availabilityStream
                  .map((event) => AsyncValue.ready(event)),
              initialData: const AsyncValue.loading(),
              catchError: (context, error) => AsyncValue.error(error),
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
                            body: const BiometryModalBody(),
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
                  body: const LanguageModalBody(),
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
        child: FutureProvider<AsyncValue<PackageInfo>>(
          create: (context) => PackageInfo.fromPlatform().then((value) => AsyncValue.ready(value)),
          initialData: const AsyncValue.loading(),
          catchError: (context, error) => AsyncValue.error(error),
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
