import 'dart:math' as math;

import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../generated/assets.gen.dart';
import '../design.dart';
import '../theme.dart';
import 'crystal_bottom_sheet.dart';
import 'ink_well.dart';

enum CrystalSelectorBehaviour {
  platform,
  dropdown,
  wheel,
}

class CrystalValueDropdownConfiguration<T> {
  const CrystalValueDropdownConfiguration({
    this.itemSize = 38.0,
    this.itemBuilder,
    this.maximumItemsAtViewport = 3,
    this.opensBelow = true,
    this.animated = true,
  });

  final double itemSize;
  final int maximumItemsAtViewport;

  final Widget Function(T)? itemBuilder;
  final bool opensBelow;
  final bool animated;

  Alignment get _targetAnchor => opensBelow ? Alignment.bottomCenter : Alignment.topCenter;

  Alignment get _followerAnchor => -_targetAnchor;
}

class CrystalValueWheelConfiguration<T> {
  const CrystalValueWheelConfiguration({
    this.itemSize = 36.0,
    this.overlay = const CrystalWheelSelectionOverlay(),
    this.itemBuilder,
  });

  final double itemSize;
  final Widget overlay;
  final Widget Function(T)? itemBuilder;
}

class CrystalValueSelector<T> extends StatefulWidget {
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

  final T selectedValue;
  final List<T> options;
  final String Function(T) nameOfOption;
  final ValueChanged<T> onSelect;

  final CrystalSelectorBehaviour behaviour;
  final CrystalValueDropdownConfiguration<T> dropdownConfiguration;
  final CrystalValueWheelConfiguration<T> wheelConfiguration;

  @override
  _CrystalValueSelectorState<T> createState() => _CrystalValueSelectorState<T>();
}

class _CrystalValueSelectorState<T> extends State<CrystalValueSelector<T>> {
  late final _link = LayerLink();
  late final _scrollController = ScrollController();
  late final _entryIsShowing = ValueNotifier<bool>(false);
  OverlayEntry? _entry;

  static const _kDropdownBorder = BorderSide(color: CrystalColor.divider, width: 1.5);

  @override
  void dispose() {
    _entryIsShowing.dispose();
    _scrollController.dispose();
    _entry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CompositedTransformTarget(
        link: _link,
        child: CrystalInkWell(
          onTap: _showSelector,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                          fontSize: 16.0,
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
                    valueListenable: _entryIsShowing,
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

  Widget _buildDropdown(BuildContext context) => Stack(
        children: [
          GestureDetector(
            onTap: _hideDropdown,
            behavior: HitTestBehavior.opaque,
            child: const SizedBox.expand(),
          ),
          CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: widget.dropdownConfiguration._targetAnchor,
            followerAnchor: widget.dropdownConfiguration._followerAnchor,
            child: Material(
              type: MaterialType.card,
              elevation: 4.0,
              color: CrystalColor.primary,
              child: ValueListenableBuilder<bool>(
                valueListenable: _entryIsShowing,
                builder: (context, isShowing, child) => AnimatedContainer(
                  duration: widget.dropdownConfiguration.animated ? const Duration(milliseconds: 200) : Duration.zero,
                  constraints: BoxConstraints(
                    maxWidth: _link.leaderSize!.width,
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
                      top: widget.dropdownConfiguration.opensBelow ? BorderSide.none : _kDropdownBorder,
                      bottom: widget.dropdownConfiguration.opensBelow ? _kDropdownBorder : BorderSide.none,
                      left: _kDropdownBorder,
                      right: _kDropdownBorder,
                    ),
                  ),
                  child: FadingEdgeScrollView.fromScrollView(
                    child: ListView.separated(
                      shrinkWrap: true,
                      reverse: !widget.dropdownConfiguration.opensBelow,
                      padding: EdgeInsets.zero,
                      controller: _scrollController,
                      itemCount: widget.options.length,
                      separatorBuilder: (_, __) => const Divider(height: 1.0, thickness: 1.0),
                      itemBuilder: (context, index) => Material(
                        type: MaterialType.transparency,
                        child: CrystalInkWell(
                          onTap: () {
                            widget.onSelect(widget.options[index]);
                            _hideDropdown();
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
                                    fontSize: 16.0,
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

  Future<void> _showSelector() {
    switch (widget.behaviour) {
      case CrystalSelectorBehaviour.dropdown:
        return _showDropdown();
      case CrystalSelectorBehaviour.wheel:
        return _showWheel();

      default:
        return Platform.isIOS ? _showWheel() : _showDropdown();
    }
  }

  Future<void> _showDropdown() async {
    if (_entryIsShowing.value) return;

    final overlay = Overlay.of(context);
    if (overlay != null) {
      _entry?.remove();
      SchedulerBinding.instance?.addPostFrameCallback(
        (timeStamp) => _entryIsShowing.value = true,
      );
      _entry = OverlayEntry(builder: _buildDropdown);
      overlay.insert(_entry!);
    }
  }

  Future<void> _hideDropdown() async {
    if (!_entryIsShowing.value) return;

    final entry = _entry;
    if (entry != null) {
      _entry = null;
      _entryIsShowing.value = false;
      Future.delayed(const Duration(milliseconds: 200), entry.remove);
    }
  }

  Future<void> _showWheel() async {
    _entryIsShowing.value = true;

    final selectedIndex = math.max(widget.options.indexOf(widget.selectedValue), 0);
    final scrollController = FixedExtentScrollController(initialItem: selectedIndex);

    await CrystalBottomSheet.show(
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
    _entryIsShowing.value = false;

    Future.delayed(const Duration(milliseconds: 200), scrollController.dispose);
  }
}

class CrystalWheelSelectionOverlay extends StatelessWidget {
  const CrystalWheelSelectionOverlay({this.height = 28.0});

  final double height;

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
