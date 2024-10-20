import 'package:ever_wallet/application/main/browser/browser_tabs/browser_tabs_cubit/browser_tabs_notifiers.dart';
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/application/util/extensions/iterable_extensions.dart';
import 'package:ever_wallet/data/models/browser_tabs_dto.dart';
import 'package:ever_wallet/data/models/site_meta_data.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:ever_wallet/logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:tuple/tuple.dart';

part 'browser_tabs_cubit.freezed.dart';

/// Cubit to manage browser tabs
class BrowserTabsCubit extends Cubit<BrowserTabsCubitState> {
  final HiveSource _hiveSource;
  final SitesMetaDataRepository metaDataRepository;

  factory BrowserTabsCubit(HiveSource hiveSource, SitesMetaDataRepository metaDataRepository) {
    final activeIndex = hiveSource.browserTabsLastIndex;
    return BrowserTabsCubit._(
      hiveSource,
      metaDataRepository,
      BrowserTabsList(
        hiveSource.browserTabs
            .mapIndex((t, i) => BrowserTabNotifier(t, i, i == activeIndex))
            .toList(),
        activeIndex,
      ),
    );
  }

  BrowserTabsCubit._(this._hiveSource, this.metaDataRepository, this._tabsDto)
      : super(
          BrowserTabsCubitState.hideTabs(_tabsDto, _tabsDto.lastActiveIndex, _tabsDto.tabs.length),
        ) {
    if (_tabsDto.lastActiveIndex == -1) {
      openNewTab();
    }
  }

  BrowserTabsList _tabsDto;

  int get tabsCount => _tabsDto.tabs.length;

  List<BrowserTab> get tabs => _tabsDto.tabsDto;

  List<BrowserTabNotifier> get tabsNotifiers => _tabsDto.tabs;

  int get activeTabIndex => _tabsDto.lastActiveIndex;

  BrowserTab? get activeTab =>
      activeTabIndex >= 0 && activeTabIndex < tabs.length
          ? tabs[activeTabIndex]
          : null;

  void showTabs() => emit(
        BrowserTabsCubitState.showTabs(_tabsDto, _tabsDto.lastActiveIndex, _tabsDto.tabs.length),
      );

  void hideTabs() => emit(
        BrowserTabsCubitState.hideTabs(_tabsDto, _tabsDto.lastActiveIndex, _tabsDto.tabs.length),
      );

  void openTab(int tabIndex) {
    _tabsDto.lastActiveIndex = tabIndex;
    _hiveSource.saveBrowserTabsLastIndex(tabIndex);
    hideTabs();
  }

  Future<void> openNewTab([String? url]) async {
    late final BrowserTab tab;

    if (url == null) {
      tab = const BrowserTab(url: aboutBlankPage, image: '', title: '', lastScrollPosition: 0);
    } else {
      final meta = await _getSiteMetaData(url);
      tab = BrowserTab(url: url, image: meta.image, title: meta.title, lastScrollPosition: 0);
    }

    _tabsDto.addTab(tab);
    _saveTabs();
    _saveIndex();
    hideTabs();
  }

  Future<void> updateCurrentTab(String url) async {
    if (activeTab?.url == url) return;

    final meta = await _getSiteMetaData(url);
    final tab = BrowserTab(url: url, image: meta.image, title: meta.title, lastScrollPosition: 0);
    _tabsDto.updateCurrentTab(tab);
    _saveTabs();
  }

  /// Data updates when user scrolls web page, but not every tick.
  /// Mustn't be called at home page.
  Future<void> updateCurrentTabData(int? scrollPosition, Uint8List? screenshot) async {
    if (activeTabIndex == -1) return;
    _tabsDto.updateCurrentTabData(scrollPosition, screenshot);
    _saveTabs();
  }

  void closeTab(int tabIndex) {
    final newIndex = _tabsDto.removeTab(tabIndex);
    if (newIndex != -1) {
      _saveTabs();
      _saveIndex();
      showTabs();
    } else {
      openNewTab();
    }
  }

  void closeAllTabs() {
    _tabsDto.closeAllTabs();
    openNewTab();
  }

  /// TODO: add saving via stream with throttle or optimize saving
  void _saveTabs() => _hiveSource.saveBrowserTabs(tabs);

  void _saveIndex() => _hiveSource.saveBrowserTabsLastIndex(activeTabIndex);

  Future<SiteMetaData> _getSiteMetaData(String url) async {
    try {
      final meta = await metaDataRepository.getSiteMetaData(url);
      return meta;
    } catch (e, t) {
      logger.e('Failed to load tab MetaData', e, t);
    }

    return SiteMetaData(url: url);
  }
}

@freezed
class BrowserTabsCubitState with _$BrowserTabsCubitState {
  /// [currentIndex] and [tabsCount] is used to simulate state changing
  const factory BrowserTabsCubitState.showTabs(
    BrowserTabsList tabs,
    int currentIndex,
    int tabsCount,
  ) = _ShowTabs;

  /// [currentIndex] and [tabsCount] is used to simulate state changing
  const factory BrowserTabsCubitState.hideTabs(
    BrowserTabsList tabs,
    int currentIndex,
    int tabsCount,
  ) = _HideTabs;
}
