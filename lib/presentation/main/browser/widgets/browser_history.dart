import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/repositories/search_history_repository.dart';
import '../../../../generated/assets.gen.dart';
import '../../../../injection.dart';
import '../../../../providers/common/search_history_provider.dart';
import '../../../common/widgets/custom_icon_button.dart';
import '../custom_in_app_web_view_controller.dart';

class BrowserHistory extends StatelessWidget {
  final Completer<CustomInAppWebViewController> controller;
  final FocusNode urlFocusNode;

  const BrowserHistory({
    Key? key,
    required this.controller,
    required this.urlFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.white,
        child: Consumer(
          builder: (context, ref, child) {
            final searchHistory = ref
                .watch(searchHistoryProvider)
                .maybeWhen(
                  data: (data) => data,
                  orElse: () => <String>[],
                )
                .reversed;

            return ListView(
              physics: const ClampingScrollPhysics(),
              children: searchHistory
                  .map(
                    (e) => tile(
                      key: ValueKey(e),
                      entry: e,
                    ),
                  )
                  .toList(),
            );
          },
        ),
      );

  Widget tile({
    required Key key,
    required String entry,
  }) =>
      Material(
        key: key,
        color: Colors.white,
        child: InkWell(
          onTap: () {
            getIt.get<SearchHistoryRepository>().addSearchHistoryEntry(entry);

            urlFocusNode.unfocus();

            controller.future.then((v) => v.parseAndLoadUrl(entry));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    entry,
                    style: const TextStyle(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CustomIconButton(
                  onPressed: () => getIt.get<SearchHistoryRepository>().removeSearchHistoryEntry(entry),
                  icon: Assets.images.iconCross.svg(),
                ),
              ],
            ),
          ),
        ),
      );
}
