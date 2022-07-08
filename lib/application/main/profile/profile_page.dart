import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/seed_creation/add_new_seed_page.dart';
import 'package:ever_wallet/application/common/theme.dart';
import 'package:ever_wallet/application/common/widgets/crystal_bottom_sheet.dart';
import 'package:ever_wallet/application/main/profile/biometry_modal_body.dart';
import 'package:ever_wallet/application/main/profile/change_seed_phrase_password_modal_body.dart';
import 'package:ever_wallet/application/main/profile/derive_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/export_seed_phrase_modal_body.dart';
import 'package:ever_wallet/application/main/profile/key_removement_modal/show_key_removement_modal.dart';
import 'package:ever_wallet/application/main/profile/language_modal_body.dart';
import 'package:ever_wallet/application/main/profile/logout_modal/show_logout_modal.dart';
import 'package:ever_wallet/application/main/profile/name_new_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/rename_key_modal_body.dart';
import 'package:ever_wallet/application/main/profile/seed_phrase_export_page.dart';
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

  static final _longDivider = Container(
    color: CrystalColor.divider,
    height: 1,
  );

  static final _shortDivider = Container(
    margin: const EdgeInsetsDirectional.only(start: 16),
    child: _longDivider,
  );

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
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
          AppLocalizations.of(context)!.profile,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 16),
              controller: scrollController,
              child: StreamProvider<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>(
                create: (context) => context
                    .read<KeysRepository>()
                    .mappedKeysStream
                    .map((event) => AsyncValue.ready(event)),
                initialData: const AsyncValue.loading(),
                catchError: (context, error) => AsyncValue.error(error),
                builder: (context, child) {
                  final keys = context
                      .watch<AsyncValue<Map<KeyStoreEntry, List<KeyStoreEntry>?>>>()
                      .maybeWhen(
                        ready: (value) => value,
                        orElse: () => <KeyStoreEntry, List<KeyStoreEntry>?>{},
                      );

                  return StreamProvider<AsyncValue<KeyStoreEntry?>>(
                    create: (context) => context
                        .read<KeysRepository>()
                        .currentKeyStream
                        .map((event) => AsyncValue.ready(event)),
                    initialData: const AsyncValue.loading(),
                    catchError: (context, error) => AsyncValue.error(error),
                    builder: (context, child) {
                      final currentKey = context.watch<AsyncValue<KeyStoreEntry?>>().maybeWhen(
                            ready: (value) => value,
                            orElse: () => null,
                          );

                      return buildSettingsItemsList(
                        keys: keys,
                        currentKey: currentKey,
                      );
                    },
                  );
                },
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
            title: AppLocalizations.of(context)!.seeds,
            children: [
              if (keys.isNotEmpty)
                buildSeedsList(
                  selectedSeed: currentKey,
                  seeds: keys,
                  onAdd: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const AddNewSeedPage(),
                      ),
                    );
                  },
                  onSelect: (seed) => context.read<KeysRepository>().setCurrentKey(seed),
                  showAddAction: true,
                ),
            ],
          ),
          buildSection(
            title: AppLocalizations.of(context)!.current_seed_preferences,
            children: [
              buildSectionAction(
                title: AppLocalizations.of(context)!.export_seed,
                onTap: keys.isNotEmpty && currentKey != null
                    ? () async {
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

                            final phrase = await context.read<KeysRepository>().exportKey(
                                  publicKey: currentKey.publicKey,
                                  password: password,
                                );

                            if (!mounted) return;

                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (context) => SeedPhraseExportPage(phrase: phrase),
                              ),
                            );
                          } catch (err) {
                            if (!mounted) return;

                            showCrystalBottomSheet<void>(
                              context,
                              title: ExportSeedPhraseModalBody.title(context),
                              body: ExportSeedPhraseModalBody(publicKey: currentKey.publicKey),
                            );
                          }
                        } else {
                          if (!mounted) return;

                          showCrystalBottomSheet<void>(
                            context,
                            title: ExportSeedPhraseModalBody.title(context),
                            body: ExportSeedPhraseModalBody(publicKey: currentKey.publicKey),
                          );
                        }
                      }
                    : null,
              ),
              buildSectionAction(
                title: AppLocalizations.of(context)!.remove_seed,
                onTap: keys.isNotEmpty && currentKey != null
                    ? () => showKeyRemovementDialog(
                          context: context,
                          publicKey: currentKey.publicKey,
                        )
                    : null,
              ),
              buildSectionAction(
                title: AppLocalizations.of(context)!.change_seed_password,
                onTap: keys.isNotEmpty && currentKey != null
                    ? () => showCrystalBottomSheet<void>(
                          context,
                          title: AppLocalizations.of(context)!.change_seed_password,
                          body: ChangeSeedPhrasePasswordModalBody(publicKey: currentKey.publicKey),
                        )
                    : null,
              ),
              if (currentKey != null && currentKey.isNotLegacy && currentKey.isMaster)
                buildSectionAction(
                  title: AppLocalizations.of(context)!.derive_key,
                  onTap: keys.isNotEmpty
                      ? () async {
                          final name = await showCrystalBottomSheet<String?>(
                            context,
                            title: NameNewKeyModalBody.title(context),
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

                                showCrystalBottomSheet<void>(
                                  context,
                                  title: DeriveKeyModalBody.title(context),
                                  body: DeriveKeyModalBody(
                                    publicKey: currentKey.publicKey,
                                    name: name.isNotEmpty ? name : null,
                                  ),
                                );
                              }
                            } else {
                              if (!mounted) return;

                              showCrystalBottomSheet<void>(
                                context,
                                title: DeriveKeyModalBody.title(context),
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
                title: AppLocalizations.of(context)!.rename_key,
                onTap: keys.isNotEmpty && currentKey != null
                    ? () {
                        showCrystalBottomSheet<void>(
                          context,
                          title: AppLocalizations.of(context)!.enter_new_name,
                          body: RenameKeyModalBody(publicKey: currentKey.publicKey),
                        );
                      }
                    : null,
              ),
            ],
          ),
          buildSection(
            title: AppLocalizations.of(context)!.wallet_preferences,
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
                          title: AppLocalizations.of(context)!.biometry,
                          onTap: () {
                            showCrystalBottomSheet<void>(
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
                  showCrystalBottomSheet<void>(
                    context,
                    title: AppLocalizations.of(context)!.language,
                    body: const LanguageModalBody(),
                  );
                },
              ),
            ],
          ),
          buildSection(
            children: [
              buildSectionAction(
                isDestructive: true,
                title: AppLocalizations.of(context)!.logout,
                onTap: () => showLogoutDialog(context: context),
              ),
            ],
          ),
          buildAppVersion(),
        ],
      );

  Widget buildSeedsList({
    KeyStoreEntry? selectedSeed,
    required Map<KeyStoreEntry, List<KeyStoreEntry>?> seeds,
    required void Function(KeyStoreEntry) onSelect,
    required void Function() onAdd,
    required bool showAddAction,
  }) {
    final children = <Widget>[];
    final divider = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(52, 0, 0, 0),
      child: ProfilePage._longDivider,
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
        title: AppLocalizations.of(context)!.add_seed,
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
    required void Function(KeyStoreEntry) onSelect,
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

    childrenWithDividers.add(ProfilePage._longDivider);

    if (children.isNotEmpty) {
      for (final child in children.sublist(0, children.length - 1)) {
        childrenWithDividers.add(child);
        childrenWithDividers.add(ProfilePage._shortDivider);
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

    childrenWithDividers.add(ProfilePage._longDivider);

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
        child: InkWell(
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
        child: FutureProvider<AsyncValue<PackageInfo>>(
          create: (context) => PackageInfo.fromPlatform().then((value) => AsyncValue.ready(value)),
          initialData: const AsyncValue.loading(),
          catchError: (context, error) => AsyncValue.error(error),
          builder: (context, child) => context.watch<AsyncValue<PackageInfo>>().maybeWhen(
                ready: (value) {
                  final version = value.version;
                  final buildNumber = value.buildNumber;

                  return Text(
                    AppLocalizations.of(context)!.version_v_b(version, buildNumber),
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
