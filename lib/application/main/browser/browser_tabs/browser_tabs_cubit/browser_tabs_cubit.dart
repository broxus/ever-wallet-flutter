// ignore_for_file: parameter_assignments
import 'package:ever_wallet/application/main/browser/utils.dart';
import 'package:ever_wallet/data/models/browser_tabs_dto.dart';
import 'package:ever_wallet/data/repositories/sites_meta_data_repository.dart';
import 'package:ever_wallet/data/sources/local/hive/hive_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'browser_tabs_cubit.freezed.dart';

/// Cubit to manage browser tabs
class BrowserTabsCubit extends Cubit<BrowserTabsCubitState> {
  final HiveSource _hiveSource;
  final SitesMetaDataRepository metaDataRepository;
  final ValueChanged<String> openUrl;

  BrowserTabsCubit(this._hiveSource, this.openUrl, this.metaDataRepository)
      : _tabsDto = _hiveSource.browserTabs,
        super(BrowserTabsCubitState.hideTabs(_hiveSource.browserTabs)) {
    if (_tabsDto.lastActiveTabIndex == -1) {
      openNewTab();
    }
  }

  BrowserTabsDto _tabsDto;

  int get tabsCount => _tabsDto.tabs.length;

  List<BrowserTab> get tabs => _tabsDto.tabs;

  int get currentTabIndex => _tabsDto.lastActiveTabIndex;

  BrowserTab get _activeTab => _tabsDto.tabs[_tabsDto.lastActiveTabIndex];

  void showTabs() => emit(BrowserTabsCubitState.showTabs(_tabsDto));

  void hideTabs() => emit(BrowserTabsCubitState.hideTabs(_tabsDto));

  void openTab(int tabIndex) {
    _tabsDto = _tabsDto.copyWith(lastActiveTabIndex: tabIndex);
    _hiveSource.saveBrowserTabs(_tabsDto);
    openUrl(_activeTab.url);
    hideTabs();
  }

  void openNewTab() {
    final tabs = List<BrowserTab>.from(_tabsDto.tabs);
    tabs.add(const BrowserTab(url: aboutBlankPage, image: '', title: ''));
    _tabsDto = _tabsDto.copyWith(tabs: tabs, lastActiveTabIndex: tabs.length - 1);
    openUrl(aboutBlankPage);
    hideTabs();
  }

  Future<void> updateCurrentTab(String url, [String? image, String? title]) async {
    if (_tabsDto.lastActiveTabIndex != -1 && _activeTab.url == url) return;

    final tabs = List<BrowserTab>.from(_tabsDto.tabs);
    if (image == null || title == null) {
      final meta = await metaDataRepository.getSiteMetaData(url);
      image = meta.image;
      title = meta.title;
    }
    final tab = BrowserTab(url: url, image: image, title: title);
    if (tabs.isEmpty) {
      tabs.add(tab);
    } else {
      tabs[_tabsDto.lastActiveTabIndex] = tab;
    }
    _tabsDto = _tabsDto.copyWith(tabs: tabs);
    hideTabs();
  }

  void closeTab(int tabIndex) {
    final prevIndex = _tabsDto.lastActiveTabIndex;
    final tabs = List<BrowserTab>.from(_tabsDto.tabs);
    tabs.removeAt(tabIndex);

    int newIndex;
    // "!" - deleted, "." - current
    // 0, .1, !2 - index didn't change
    if (prevIndex < tabIndex) {
      newIndex = prevIndex;
      // 0, !1, .2 - index moved to deleted position (all tabs shifted)
    } else if (tabs.length > tabIndex) {
      newIndex = tabIndex;
      // 0, .!1 or .!0, 1 - select last tab
    } else if (tabs.isNotEmpty) {
      newIndex = tabs.length - 1;
      // no tabs in list
    } else {
      newIndex = -1;
    }

    _tabsDto = _tabsDto.copyWith(
      tabs: tabs,
      lastActiveTabIndex: newIndex,
    );
    if (newIndex != -1) {
      openUrl(_activeTab.url);
      showTabs();
    } else {
      openNewTab();
    }
  }

  void closeAllTabs() {
    _tabsDto = _tabsDto.copyWith(lastActiveTabIndex: -1, tabs: []);
    _hiveSource.saveBrowserTabs(_tabsDto);
    openNewTab();
  }
}

@freezed
class BrowserTabsCubitState with _$BrowserTabsCubitState {
  const factory BrowserTabsCubitState.showTabs(BrowserTabsDto tabs) = _ShowTabs;

  const factory BrowserTabsCubitState.hideTabs(BrowserTabsDto tabs) = _HideTabs;
}
