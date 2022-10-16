import 'package:ever_wallet/application/common/general/button/primary_icon_button.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/main/browser/widgets/browser_home.dart';
import 'package:ever_wallet/application/util/colors.dart';
import 'package:ever_wallet/data/models/browser_tabs_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const childAspectRation = 160 / 190;

class BrowserTabItem extends StatefulWidget {
  const BrowserTabItem({
    required this.onClose,
    required this.onOpen,
    required this.tab,
    required this.itemWidth,
    required this.itemHeight,
    required this.isCurrentActive,
    super.key,
  });

  final VoidCallback onClose;
  final VoidCallback onOpen;
  final BrowserTab tab;
  final double itemWidth;
  final double itemHeight;
  final bool isCurrentActive;

  @override
  State<BrowserTabItem> createState() => _BrowserTabItemState();
}

class _BrowserTabItemState extends State<BrowserTabItem> {
  final slidableKey = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: slidableKey,
      closeOnScroll: false,
      endActionPane: ActionPane(
        closeThreshold: 0.55,
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          dismissThreshold: 0.5,
          onDismissed: widget.onClose,
        ),
        children: const [],
      ),
      child: Builder(
        builder: (context) {
          final controller = Slidable.of(context)!;
          return ValueListenableBuilder<double>(
            valueListenable: controller.animation,
            builder: (_, controllerValue, __) {
              return Opacity(
                opacity: 1 - controllerValue,
                child: GestureDetector(
                  onTap: widget.onOpen,
                  child: Material(
                    color: Colors.white,
                    elevation: 5,
                    child: SizedBox(
                      width: widget.itemWidth,
                      height: widget.itemHeight,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Positioned.fill(
                            child: SizedBox(
                              width: widget.itemWidth,
                              height: widget.itemHeight,
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1.5,
                                      color: widget.isCurrentActive
                                          ? ColorsRes.bluePrimary400
                                          : Colors.transparent,
                                    ),
                                  ),
                                  child: FittedBox(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxHeight: 400,
                                        maxWidth: 400 * childAspectRation,
                                      ),
                                      child: widget.tab.url == aboutBlankPage ||
                                              widget.tab.url.isEmpty
                                          ? BrowserHome(changeUrl: (_) {})
                                          : Container(
                                              decoration: const BoxDecoration(color: Colors.white),
                                              width: double.infinity,
                                              child: widget.tab.screenshot != null
                                                  ? Image.memory(
                                                      widget.tab.screenshot!,
                                                      fit: BoxFit.cover,
                                                    )
                                                  : null,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: PrimaryIconButton(
                              backgroundColor: ColorsRes.blue950,
                              outerPadding: EdgeInsets.zero,
                              innerPadding: const EdgeInsets.all(4),
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: ColorsRes.bluePrimary400,
                              ),
                              onPressed: widget.onClose,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
