import 'package:flutter/material.dart';

import '../../data/child_avatar.dart';

/// Circular tile that renders an illustrated [ChildAvatar].
class ChildAvatarCircle extends StatelessWidget {
  const ChildAvatarCircle({
    super.key,
    required this.avatar,
    this.size = 60,
  });

  final ChildAvatar avatar;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: avatar.gradient,
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        avatar.icon,
        size: size * 0.5,
        color: avatar.foreground,
      ),
    );
  }
}
