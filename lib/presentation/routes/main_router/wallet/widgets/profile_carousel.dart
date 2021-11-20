import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nekoton_flutter/nekoton_flutter.dart';

import '../../../../design/design.dart';
import 'new_account_card.dart';
import 'wallet_card.dart';

class ProfileCarousel extends StatefulWidget {
  final bool loading;
  final int initialIndex;
  final List<AssetsList> accounts;
  final VoidCallback? onScrollStart;
  final void Function(int)? onPageChanged;
  final void Function(int)? onPageSelected;

  const ProfileCarousel({
    Key? key,
    required this.accounts,
    this.loading = false,
    this.initialIndex = 0,
    this.onScrollStart,
    this.onPageChanged,
    this.onPageSelected,
  }) : super(key: key);

  @override
  _ProfileCarouselState createState() => _ProfileCarouselState();
}

class _ProfileCarouselState extends State<ProfileCarousel> {
  late final PageController pageController;

  bool onScroll = false;

  void pageListener() {
    final currentPagePosition = pageController.page ?? 0;
    final currentPage = currentPagePosition.round();
    if (onScroll && currentPage == currentPagePosition) {
      widget.onPageSelected?.call(currentPage);
      onScroll = false;
    } else if (!onScroll && currentPage != currentPagePosition) {
      onScroll = true;
      widget.onScrollStart?.call();
    }
  }

  @override
  void didUpdateWidget(covariant ProfileCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.loading != oldWidget.loading || oldWidget.accounts.length != widget.accounts.length) {
      SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
        final currentPage = pageController.page?.round() ?? 0;
        widget.onPageChanged?.call(currentPage);
        widget.onPageSelected?.call(currentPage);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.initialIndex,
      viewportFraction: 0.925,
    );
    pageController.addListener(pageListener);
    if (widget.onPageSelected != null || widget.onPageChanged != null) {
      WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
        widget.onPageChanged?.call(pageController.initialPage);
        widget.onPageSelected?.call(pageController.initialPage);
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            width: double.infinity,
            child: AnimatedSwitcher(
              duration: kThemeAnimationDuration,
              child: PageView.builder(
                itemCount: widget.accounts.length + 1,
                controller: pageController,
                onPageChanged: widget.onPageChanged,
                itemBuilder: (context, index) => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (pageController.page?.round() != index) {
                      pageController.animateToPage(
                        index,
                        duration: kThemeAnimationDuration,
                        curve: Curves.decelerate,
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.5),
                    child: index < widget.accounts.length
                        ? WalletCard(
                            key: ValueKey(widget.accounts[index].address),
                            address: widget.accounts[index].address,
                          )
                        : NewAccountCard(),
                  ),
                ),
              ),
            ),
          ),
          const CrystalDivider(height: 16),
          pageIndicators(),
        ],
      );

  Widget pageIndicators() => SizedBox(
        height: 8,
        child: AnimatedAppearance(
          delay: const Duration(milliseconds: 250),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.accounts.length + 1; i++)
                AnimatedBuilder(
                  animation: pageController,
                  builder: (context, child) {
                    final currentPage = pageController.page ?? 0;
                    final multiply = (currentPage - i).abs();
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: CircleIcon(
                        size: 8 - 2 * multiply.clamp(0, 1),
                        color: multiply < 0.5 ? Colors.white : const Color(0xFFA6AEBD),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
}
