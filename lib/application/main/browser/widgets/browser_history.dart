import 'dart:async';

import 'package:ever_wallet/application/common/async_value.dart';
import 'package:ever_wallet/application/common/widgets/custom_icon_button.dart';
import 'package:ever_wallet/application/main/browser/extensions.dart';
import 'package:ever_wallet/data/repositories/search_history_repository.dart';
import 'package:ever_wallet/generated/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

class BrowserHistory extends StatelessWidget {
  final Completer<InAppWebViewController> controller;
  final FocusNode urlFocusNode;

  const BrowserHistory({
    Key? key,
    required this.controller,
    required this.urlFocusNode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ColoredBox(
        color: Colors.white,
        child: StreamProvider<AsyncValue<List<String>>>(
          create: (context) => context
              .read<SearchHistoryRepository>()
              .searchHistoryStream
              .map((event) => AsyncValue.ready(event)),
          initialData: const AsyncValue.loading(),
          catchError: (context, error) => AsyncValue.error(error),
          builder: (context, child) {
            final searchHistory = context
                .watch<AsyncValue<List<String>>>()
                .maybeWhen(
                  ready: (value) => value,
                  orElse: () => <String>[],
                )
                .reversed;

            return ListView(
              physics: const ClampingScrollPhysics(),
              children: searchHistory
                  .map(
                    (e) => tile(
                      context: context,
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
    required BuildContext context,
    required Key key,
    required String entry,
  }) =>
      Material(
        key: key,
        color: Colors.white,
        child: InkWell(
          onTap: () {
            context.read<SearchHistoryRepository>().addSearchHistoryEntry(entry);

            urlFocusNode.unfocus();

            controller.future.then((v) => v.tryLoadUrl(entry));
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
                  onPressed: () =>
                      context.read<SearchHistoryRepository>().removeSearchHistoryEntry(entry),
                  icon: Assets.images.iconCross.svg(),
                ),
              ],
            ),
          ),
        ),
      );
}
