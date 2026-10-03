import 'package:flutter/material.dart';

/// Calls [onLoadMore] when the list scrolls within 200px of its end. Repeat
/// calls are expected: each cubit's `loadMore` guards on its own
/// loading-more / has-more state.
mixin ScrollPaginationMixin<T extends StatefulWidget> on State<T> {
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      onLoadMore();
    }
  }

  void onLoadMore();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
