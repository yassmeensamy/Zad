import 'dart:async';

import 'package:flutter/material.dart';

mixin ScrollPaginationMixin<T extends StatefulWidget> on State<T> {
  Timer? _scrollDebounce;
  bool _isScrolling = false;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isScrolling) return;

    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      _isScrolling = true;

      onLoadMore();

      _scrollDebounce = Timer(const Duration(milliseconds: 500), () {
        _isScrolling = false;
      });
    }
  }

  void onLoadMore();

  @override
  void dispose() {
    _scrollDebounce?.cancel();
    scrollController.dispose();
    super.dispose();
  }
}
