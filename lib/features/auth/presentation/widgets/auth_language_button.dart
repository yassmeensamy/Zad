import 'package:flutter/material.dart';

import '../../../../core/l10n/app_languages.dart';
import '../../../../theme/theme.dart';
import '../../../language/presentation/modals/language_dialog.dart';

/// Compact language switcher for the unauthenticated auth screens.
///
/// On login/signup the user has no backend account yet, so the change is kept
/// local-only via [LanguageDialog]'s `shouldSkipBackend` flag — the preference
/// is persisted to cache and `easy_localization`, never sent to the API.
class AuthLanguageButton extends StatelessWidget {
  const AuthLanguageButton({super.key});

  void _onTap(BuildContext context) {
    LanguageDialog.show(context, shouldSkipBackend: true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final label = context.appLanguage.nativeName;
    return Material(
      color: colors.overlayLight,
      shape: StadiumBorder(
        side: BorderSide(color: colors.borderSubtle),
      ),
      child: InkWell(
        onTap: () => _onTap(context),
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.translate_rounded,
                size: 16,
                color: colors.olive,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.olive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
