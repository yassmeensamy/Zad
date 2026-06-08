import 'package:flutter/material.dart';

import '../../../../core/widgets/app_scaffold.dart';

class TeamScaffold extends StatelessWidget {
  const TeamScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNav,
    this.extendBody = false,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNav;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNav,
      extendBody: extendBody,
      extendBodyBehindAppBar: appBar != null,
      safeArea: true,
      body: child,
    );
  }
}
