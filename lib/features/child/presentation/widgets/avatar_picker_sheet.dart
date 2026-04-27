import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/widgets/responsive_text.dart';
import '../../../../theme/theme.dart';
import '../../../onboarding_flow/data/child_avatar.dart';
import '../../../onboarding_flow/presentation/widgets/child_avatar_circle.dart';
import 'custom_modal.dart';

class AvatarPickerSheet extends StatelessWidget {
  const AvatarPickerSheet({super.key, required this.current});

  final ChildAvatar current;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return CustomModal(
      title: ResponsiveText(
        'create_profiles.sheet_title',
        textAlign: TextAlign.center,
        style: GoogleFonts.fraunces(fontSize: 20, color: colors.oliveDeep),
      ),
      subtitle: ResponsiveText(
        'create_profiles.sheet_sub',
        textAlign: TextAlign.center,
        style: GoogleFonts.inter(fontSize: 11, color: AppColors.dateSoft),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1,
        ),
        itemCount: ChildAvatar.values.length,
        itemBuilder: (_, i) {
          final a = ChildAvatar.values[i];
          final active = a == current;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).pop(a),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: active ? colors.olive : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                padding: const EdgeInsets.all(2),
                child: ChildAvatarCircle(avatar: a, size: 60),
              ),
            ),
          );
        },
      ),
    );
  }
}
