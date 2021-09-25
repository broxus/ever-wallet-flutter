import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../../../domain/blocs/misc/connected_sites_bloc.dart';
import '../../../../domain/models/connected_site.dart';
import '../../../../injection.dart';
import '../../../design/design.dart';

class ConnectedSitesBody extends StatefulWidget {
  final String address;

  const ConnectedSitesBody({
    Key? key,
    required this.address,
  }) : super(key: key);

  static String get title => LocaleKeys.connected_sites_modal_title.tr();

  @override
  _ConnectedSitesBodyState createState() => _ConnectedSitesBodyState();
}

class _ConnectedSitesBodyState extends State<ConnectedSitesBody> {
  late final ConnectedSitesBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = getIt.get<ConnectedSitesBloc>(param1: widget.address);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ConnectedSitesBloc, ConnectedSitesState>(
        bloc: bloc,
        builder: (context, state) => state.maybeWhen(
          ready: (connectedSites) => FadingEdgeScrollView.fromScrollView(
            shouldDisposeScrollController: true,
            child: ListView.separated(
              shrinkWrap: true,
              controller: ScrollController(),
              padding: EdgeInsets.only(
                top: 8,
                bottom: math.max(16, context.safeArea.bottom),
              ),
              itemCount: connectedSites.length + 1,
              separatorBuilder: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.5),
                child: Divider(height: 1, thickness: 1),
              ),
              itemBuilder: (context, index) => index >= connectedSites.length
                  ? CrystalButton(
                      text: LocaleKeys.add_site_dialog_title.tr(),
                      onTap: () => _showAddDialog(context),
                    )
                  : _getSiteItem(
                      context,
                      site: connectedSites[index],
                    ),
            ),
          ),
          orElse: () => const SizedBox(),
        ),
      );

  Widget _getSiteItem(
    BuildContext context, {
    required ConnectedSite site,
  }) {
    final controller = FocusedMenuController();
    return FocusedMenuHolder(
      controller: controller,
      blurBackgroundColor: CrystalColor.modalBackground,
      animateMenuItems: false,
      menuItemExtent: Platform.isIOS ? 44 : 52,
      menuOffset: const Offset(8, 8),
      blurSize: 0,
      menuWidth: context.screenSize.width * 0.4,
      bottomOffsetHeight: context.safeArea.bottom,
      menuItems: [
        FocusedMenuItem(
          title: LocaleKeys.actions_edit.tr(),
          materialIcon: Icons.edit,
          cupertinoIcon: CupertinoIcons.pencil,
          onPressed: () => _showEditDialog(
            context,
            site: site,
          ),
        ),
        FocusedMenuItem(
          title: LocaleKeys.actions_delete.tr(),
          titleColor: CrystalColor.error,
          materialIcon: Icons.delete,
          cupertinoIcon: CupertinoIcons.delete,
          onPressed: () => _showDeleteDialog(
            context,
            site: site,
          ),
        ),
      ],
      child: (isOpened) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: const ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2)),
          ),
          color: CrystalColor.primary,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const ShapeDecoration(
                shape: CircleBorder(),
                color: CrystalColor.icon,
              ),
            ),
            const CrystalDivider(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 20,
                    child: Text(
                      site.url,
                      style: const TextStyle(
                        color: CrystalColor.fontDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                    child: Text(
                      DateFormat('dd.MM.yyyy, HH:mm').format(site.time),
                      style: const TextStyle(color: CrystalColor.hintColor),
                    ),
                  ),
                ],
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: CrystalInkWell(
                onTap: () => controller.openMenu(context),
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: Icon(
                      Icons.more_vert,
                      color: isOpened ? CrystalColor.chipText : CrystalColor.icon,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddDialog(BuildContext context) async {
    final _controller = TextEditingController(text: '');
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: AnimatedPadding(
          duration: kThemeAnimationDuration,
          padding: context.keyboardInsets,
          child: Theme(
            data: ThemeData(),
            child: PlatformAlertDialog(
              title: Text(LocaleKeys.add_site_dialog_title.tr()),
              cupertino: (_, __) => CupertinoAlertDialogData(
                content: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CupertinoTextField(
                    controller: _controller,
                    autofocus: true,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              material: (_, __) => MaterialAlertDialogData(
                content: TextField(
                  controller: _controller,
                  autofocus: true,
                ),
              ),
              actions: [
                PlatformDialogAction(
                  onPressed: Navigator.of(context).pop,
                  child: Text(LocaleKeys.actions_cancel.tr()),
                ),
                PlatformDialogAction(
                  onPressed: () {
                    bloc.add(ConnectedSitesEvent.addConnectedSite(_controller.text));
                    Navigator.of(context).pop();
                  },
                  cupertino: (_, __) => CupertinoDialogActionData(
                    isDefaultAction: true,
                  ),
                  child: Text(LocaleKeys.add_site_dialog_actions_add.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), _controller.dispose);
  }

  Future<void> _showEditDialog(
    BuildContext context, {
    required ConnectedSite site,
  }) async {
    final _controller = TextEditingController(text: site.url);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: AnimatedPadding(
          duration: kThemeAnimationDuration,
          padding: context.keyboardInsets,
          child: Theme(
            data: ThemeData(),
            child: PlatformAlertDialog(
              title: Text(LocaleKeys.connected_sites_modal_options_edit.tr()),
              cupertino: (_, __) => CupertinoAlertDialogData(
                content: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: CupertinoTextField(
                    controller: _controller,
                    autofocus: true,
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ),
              material: (_, __) => MaterialAlertDialogData(
                content: TextField(
                  controller: _controller,
                  autofocus: true,
                ),
              ),
              actions: [
                PlatformDialogAction(
                  onPressed: Navigator.of(context).pop,
                  child: Text(LocaleKeys.actions_cancel.tr()),
                ),
                PlatformDialogAction(
                  onPressed: () {
                    bloc.add(ConnectedSitesEvent.removeConnectedSite(site.url));
                    bloc.add(ConnectedSitesEvent.addConnectedSite(_controller.text));
                    Navigator.of(context).pop();
                  },
                  cupertino: (_, __) => CupertinoDialogActionData(
                    isDefaultAction: true,
                  ),
                  child: Text(LocaleKeys.actions_edit.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), _controller.dispose);
  }

  Future<void> _showDeleteDialog(
    BuildContext context, {
    required ConnectedSite site,
  }) =>
      showDialog<void>(
        context: context,
        builder: (BuildContext context) => Theme(
          data: ThemeData(),
          child: PlatformAlertDialog(
            title: Text(LocaleKeys.connected_sites_modal_options_delete.tr()),
            actions: [
              PlatformDialogAction(
                onPressed: Navigator.of(context).pop,
                child: Text(LocaleKeys.actions_cancel.tr()),
              ),
              PlatformDialogAction(
                onPressed: () {
                  bloc.add(ConnectedSitesEvent.removeConnectedSite(site.url));
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
                child: Text(LocaleKeys.actions_delete.tr()),
              ),
            ],
          ),
        ),
      );
}
