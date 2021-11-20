import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ExpandablePageView extends StatefulWidget {
  final List<Widget>? children;
  final int? itemCount;
  final Widget Function(BuildContext, int)? itemBuilder;
  final PageController? controller;
  final ValueChanged<int>? onPageChanged;
  final bool reverse;
  final Duration animationDuration;
  final Curve animationCurve;
  final ScrollPhysics? physics;
  final bool pageSnapping;
  final DragStartBehavior dragStartBehavior;
  final bool allowImplicitScrolling;
  final String? restorationId;
  final Clip clipBehavior;

  final bool animateFirstPage;

  final double estimatedPageSize;

  final double maxHeight;

  const ExpandablePageView({
    this.children,
    this.itemCount,
    this.itemBuilder,
    this.controller,
    this.onPageChanged,
    this.reverse = false,
    this.animationDuration = const Duration(milliseconds: 100),
    this.animationCurve = Curves.decelerate,
    this.physics,
    this.pageSnapping = true,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.animateFirstPage = false,
    this.estimatedPageSize = 0,
    this.maxHeight = double.infinity,
    Key? key,
  })  : assert(
            (children != null && itemCount == null && itemBuilder == null) ||
                (children == null && itemCount != null && itemBuilder != null),
            'Cannot provide both children and itemBuilder\n'
            'If you need a fixed PageView, use children\n'
            'If you need a dynamically built PageView, use itemBuilder and itemCount'),
        assert(estimatedPageSize >= 0),
        super(key: key);

  @override
  _ExpandablePageViewState createState() => _ExpandablePageViewState();
}

class _ExpandablePageViewState extends State<ExpandablePageView> {
  late PageController _pageController;
  late List<double> _heights;
  int _currentPage = 0;
  int _previousPage = 0;
  bool _shouldDisposePageController = false;
  bool _firstPageLoaded = false;

  double get _currentHeight => _heights[_currentPage];

  double get _previousHeight => _heights[_previousPage];

  bool get isBuilder => widget.itemBuilder != null;

  @override
  void initState() {
    _heights = _prepareHeights();
    super.initState();
    _pageController = widget.controller ?? PageController();
    _pageController.addListener(_updatePage);
    _shouldDisposePageController = widget.controller == null;

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _firstPageLoaded = true;
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_updatePage);
    if (_shouldDisposePageController) {
      _pageController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      curve: widget.animationCurve,
      duration: _getDuration(),
      tween: Tween<double>(begin: _previousHeight, end: _currentHeight),
      builder: (context, value, child) => SizedBox(height: value, child: child),
      child: _buildPageView(),
    );
  }

  Duration _getDuration() {
    if (_firstPageLoaded) {
      return widget.animationDuration;
    }
    return widget.animateFirstPage ? widget.animationDuration : Duration.zero;
  }

  Widget _buildPageView() {
    if (isBuilder) {
      return PageView.builder(
        key: widget.key,
        controller: _pageController,
        itemBuilder: _itemBuilder,
        itemCount: widget.itemCount,
        onPageChanged: widget.onPageChanged,
        reverse: widget.reverse,
        physics: widget.physics,
        pageSnapping: widget.pageSnapping,
        dragStartBehavior: widget.dragStartBehavior,
        allowImplicitScrolling: widget.allowImplicitScrolling,
        restorationId: widget.restorationId,
        clipBehavior: widget.clipBehavior,
      );
    }
    return PageView(
      key: widget.key,
      controller: _pageController,
      onPageChanged: widget.onPageChanged,
      reverse: widget.reverse,
      physics: widget.physics,
      pageSnapping: widget.pageSnapping,
      dragStartBehavior: widget.dragStartBehavior,
      allowImplicitScrolling: widget.allowImplicitScrolling,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      children: _sizeReportingChildren(),
    );
  }

  List<double> _prepareHeights() {
    if (isBuilder) {
      return List.filled(widget.itemCount!, widget.estimatedPageSize);
    } else {
      return widget.children!.map((child) => widget.estimatedPageSize).toList();
    }
  }

  void _updatePage() {
    final newPage = _pageController.page!.round();
    if (_currentPage != newPage) {
      setState(() {
        _firstPageLoaded = true;
        _previousPage = _currentPage;
        _currentPage = newPage;
      });
    }
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final item = widget.itemBuilder!(context, index);
    return OverflowPage(
      maxHeight: widget.maxHeight,
      onSizeChange: (size) => setState(() => _heights[index] = size.height),
      child: item,
    );
  }

  List<Widget> _sizeReportingChildren() => widget.children!
      .asMap()
      .map(
        (index, child) => MapEntry(
          index,
          OverflowPage(
            maxHeight: widget.maxHeight,
            onSizeChange: (size) => setState(() => _heights[index] = size.height),
            child: child,
          ),
        ),
      )
      .values
      .toList();
}

class OverflowPage extends StatelessWidget {
  final ValueChanged<Size> onSizeChange;
  final Widget child;
  final double maxHeight;

  const OverflowPage({
    required this.onSizeChange,
    required this.child,
    this.maxHeight = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minHeight: 0,
      maxHeight: maxHeight,
      alignment: Alignment.topCenter,
      child: SizeReportingWidget(
        onSizeChange: onSizeChange,
        child: child,
      ),
    );
  }
}

class SizeReportingWidget extends StatefulWidget {
  final Widget child;
  final ValueChanged<Size> onSizeChange;

  const SizeReportingWidget({
    Key? key,
    required this.child,
    required this.onSizeChange,
  }) : super(key: key);

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  final _widgetKey = GlobalKey();
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => _notifySize());
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance!.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
          key: _widgetKey,
          child: widget.child,
        ),
      ),
    );
  }

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size!);
    }
  }
}
