import 'package:flutter/material.dart';

import '../../../home/presentation/widgets/home_why_login_section.dart';
import 'leaderboard_header.dart';

/// Shown to anonymous users in place of the rankings: the header plus the
/// "why sign in" pitch, centered and scrollable so it never overflows.
class LeaderboardGuestPrompt extends StatelessWidget {
  const LeaderboardGuestPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const LeaderboardHeader(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 22),
                    child: HomeWhyLoginSection(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
