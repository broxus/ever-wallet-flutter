import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../generated/assets.gen.dart';
import '../design.dart';
import '../theme.dart';
import 'crystal_bottom_sheet.dart';
import 'crystal_ink_well.dart';

enum CrystalSelectorBehaviour {
  platform,
  dropdown,
  wheel,
}

class CrystalValueDropdownConfiguration<T> {
  final double itemSize;
  final int maximumItemsAtViewport;
  final Widget Function(T)? itemBuilder;
  final bool opensBelow;
  final bool animated;

  const CrystalValueDropdownConfiguration({
    this.itemSize = 38,
    this.itemBuilder,
    this.maximumItemsAtViewport = 3,
    this.opensBelow = true,
    this.animated = true,
  });

  Alignment get targetAnchor => opensBelow ? Alignment.bottomCenter : Alignment.topCenter;

  Alignment get followerAnchor => -targetAnchor;
}

class CrystalValueWheelConfiguration<T> {
  final double itemSize;
  final Widget overlay;
  final Widget Function(T)? itemBuilder;

  const CrystalValueWheelConfiguration({
    this.itemSize = 36,
    this.overlay = const CrystalWheelSelectionOverlay(),
    this.itemBuilder,
  });
}

class CrystalValueSelector<T> extends StatefulWidget {
  final T selectedValue;
  final List<T> options;
  final String Function(T) nameOfOption;
  final ValueChanged<T> onSelect;
  final CrystalSelectorBehaviour behaviour;
  final CrystalValueDropdownConfiguration<T> dropdownConfiguration;
  final CrystalValueWheelConfiguration<T> wheelConfiguration;

  const CrystalValueSelector({
    Key? key,
    this.behaviour = CrystalSelectorBehaviour.platform,
    required this.selectedValue,
    required this.options,
    required this.nameOfOption,
    required this.onSelect,
    this.dropdownConfiguration = const CrystalValueDropdownConfiguration(),
    this.wheelConfiguration = const CrystalValueWheelConfiguration(),
  }) : super(key: key);

  @override
  _CrystalValueSelectorState<T> createState() => _CrystalValueSelectorState<T>();
}

class _CrystalValueSelectorState<T> extends State<CrystalValueSelector<T>> {
  static const kDropdownBorder = BorderSide(color: CrystalColor.divider, width: 1.5);
  late final link = LayerLink();
  late final scrollController = ScrollController();
  late final entryIsShowing = ValueNotifier<bool>(false);
  OverlayEntry? overlayEntry;

  @override
  void dispose() {
    entryIsShowing.dispose();
    scrollController.dispose();
    overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
        link: link,
        child: CrystalInkWell(
          onTap: showSelector,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: CrystalColor.border,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AnimatedSwitcher(
                    duration: kThemeAnimationDuration,
                    child: Align(
                      key: ValueKey('title_of_selector_option_${widget.selectedValue}'),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.nameOfOption(widget.selectedValue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          letterSpacing: 0.25,
                          color: CrystalColor.fontDark,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 18,
                  height: 20,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: entryIsShowing,
                    builder: (context, isOpened, child) => AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: isOpened
                          ? Assets.images.iconMinus.image(
                              key: const ValueKey('close_icon'),
                              width: 9,
                              height: 10,
                              color: CrystalColor.fontDark,
                            )
                          : Assets.images.iconDropdownArrow.image(
                              width: 18,
                              height: 20,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildDropdown(BuildContext context) => Stack(
        children: [
          GestureDetector(
            onTap: hideDropdown,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: link,
            showWhenUnlinked: false,
            targetAnchor: widget.dropdownConfiguration.targetAnchor,
            followerAnchor: widget.dropdownConfiguration.followerAnchor,
            child: Material(
              type: MaterialType.card,
              elevation: 4,
              color: CrystalColor.primary,
              child: ValueListenableBuilder<bool>(
                valueListenable: entryIsShowing,
                builder: (context, isShowing, child) => AnimatedContainer(
                  duration: widget.dropdownConfiguration.animated ? const Duration(milliseconds: 200) : Duration.zero,
                  constraints: BoxConstraints(
                    maxWidth: link.leaderSize!.width,
                    maxHeight: isShowing
                        ? (widget.dropdownConfiguration.maximumItemsAtViewport * widget.dropdownConfiguration.itemSize)
                        : 0,
                  ),
                  child: child,
                ),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CrystalColor.primary,
                    border: Border(
                      top: widget.dropdownConfiguration.opensBelow ? BorderSide.none : kDropdownBorder,
                      bottom: widget.dropdownConfiguration.opensBelow ? kDropdownBorder : BorderSide.none,
                      left: kDropdownBorder,
                      right: kDropdownBorder,
                    ),
                  ),
                  child: FadingEdgeScrollView.fromScrollView(
                    child: ListView.separated(
                      shrinkWrap: true,
                      reverse: !widget.dropdownConfiguration.opensBelow,
                      padding: EdgeInsets.zero,
                      controller: scrollController,
                      itemCount: widget.options.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
                      itemBuilder: (context, index) => Material(
                        type: MaterialType.transparency,
                        child: CrystalInkWell(
                          onTap: () {
                            widget.onSelect(widget.options[index]);
                            hideDropdown();
                          },
                          child: Container(
                            alignment: Alignment.centerLeft,
                            height: widget.dropdownConfiguration.itemSize,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: widget.dropdownConfiguration.itemBuilder?.call(widget.options[index]) ??
                                Text(
                                  widget.nameOfOption(widget.options[index]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: widget.selectedValue == widget.options[index]
                                        ? FontWeight.w500
                                        : FontWeight.w400,
                                    color: CrystalColor.fontDark,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );

  Future<void> showSelector() {
    switch (widget.behaviour) {
      case CrystalSelectorBehaviour.dropdown:
        return showDropdown();
      case CrystalSelectorBehaviour.wheel:
        return showWheel();

      default:
        return Platform.isIOS ? showWheel() : showDropdown();
    }
  }

  Future<void> showDropdown() async {
    if (entryIsShowing.value) return;

    final overlay = Overlay.of(context);
    if (overlay != null) {
      overlayEntry?.remove();
      SchedulerBinding.instance?.addPostFrameCallback(
        (timeStamp) => entryIsShowing.value = true,
      );
      overlayEntry = OverlayEntry(builder: buildDropdown);
      overlay.insert(overlayEntry!);
    }
  }

  Future<void> hideDropdown() async {
    if (!entryIsShowing.value) return;

    final entry = overlayEntry;
    if (entry != null) {
      overlayEntry = null;
      entryIsShowing.value = false;
      Future.delayed(const Duration(milliseconds: 200), entry.remove);
    }
  }

  Future<void> showWheel() async {
    entryIsShowing.value = true;

    final selectedIndex = math.max(widget.options.indexOf(widget.selectedValue), 0);
    final scrollController = FixedExtentScrollController(initialItem: selectedIndex);

    await showCrystalBottomSheet(
      context,
      expand: false,
      body: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: math.min(context.screenSize.height * 0.3, 240),
            minHeight: math.max(context.screenSize.height * 0.2, 140),
          ),
          child: CupertinoPicker.builder(
            onSelectedItemChanged: (index) => widget.onSelect(widget.options[index]),
            itemExtent: widget.wheelConfiguration.itemSize,
            childCount: widget.options.length,
            scrollController: scrollController,
            magnification: 1.1,
            squeeze: 1.25,
            useMagnifier: true,
            selectionOverlay: widget.wheelConfiguration.overlay,
            itemBuilder: (context, index) =>
                widget.wheelConfiguration.itemBuilder?.call(widget.options[index]) ??
                Center(
                  child: Text(
                    widget.nameOfOption(widget.options[index]),
                  ),
                ),
          ),
        ),
      ),
    );
    entryIsShowing.value = false;

    Future.delayed(const Duration(milliseconds: 200), scrollController.dispose);
  }
}

class CrystalWheelSelectionOverlay extends StatelessWidget {
  final double height;

  const CrystalWheelSelectionOverlay({this.height = 28});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            border: Border.symmetric(
              horizontal: BorderSide(color: CrystalColor.divider),
            ),
          ),
        ),
      );
}
