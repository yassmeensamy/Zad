import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/offline/presentation/cubit/connectivity_cubit.dart';
import '../../theme/theme.dart';
import 'responsive_text.dart';
import 'zaad_primary_button.dart';

/// Premium, theme-aware error-state placeholder used across the app whenever a
/// load fails. Renders a glowing warning medallion, an optional [title], a
/// [message], and a gradient retry CTA when [onRetry] is provided.
///
/// Connection-aware: while the device is offline (per [ConnectivityCubit]) it
/// automatically promotes to the "Connection lost" presentation — wifi-off glyph
/// and connectivity copy — regardless of the originating error, so every screen
/// surfaces a coherent offline state for free. Use [ErrorState.connection] to
/// force that presentation, or pass `connectionAware: false` to opt out.
/// Both adapt automatically to light/dark via the semantic color tokens.
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon = Icons.error_outline_rounded,
    this.retryLabelKey = 'common.retry',
    this.connectionAware = true,
  }) : _forceConnection = false;

  /// Connectivity-failure variant — wifi-off glyph + "connection lost" copy.
  /// Pass [message]/[title] to override the defaults for a specific surface.
  const ErrorState.connection({
    super.key,
    this.title = 'errors.connection_title',
    this.message = 'errors.connection_message',
    this.onRetry,
    this.icon = Icons.wifi_off_rounded,
    this.retryLabelKey = 'common.retry',
  }) : connectionAware = true,
       _forceConnection = true;

  /// Title / headline (translation key). Optional — omit for a terse, message-
  /// only state.
  final String? title;

  /// Supporting message (translation key).
  final String message;

  /// When provided, a gradient retry CTA is shown that invokes this.
  final VoidCallback? onRetry;

  /// Glyph rendered inside the medallion.
  final IconData icon;

  /// Translation key for the retry CTA label.
  final String retryLabelKey;

  /// When true (default), the widget swaps to the connection presentation while
  /// the device is offline. Set false to always show the provided error as-is.
  final bool connectionAware;

  /// Set by [ErrorState.connection] to always render the connectivity layout.
  final bool _forceConnection;

  @override
  Widget build(BuildContext context) {
    if (_forceConnection) return _build(context, isConnection: true);
    if (!connectionAware) return _build(context, isConnection: false);

    // Promote to the connection layout while offline. Falls back gracefully to
    // the generic layout when no [ConnectivityCubit] is in scope.
    final cubit = context.watch<ConnectivityCubit?>();
    final offline = cubit != null && cubit.state == false;
    return _build(context, isConnection: offline);
  }

  Widget _build(BuildContext context, {required bool isConnection}) {
    final colors = context.appColors;
    final accent = colors.warning;

    final effectiveIcon = isConnection ? Icons.wifi_off_rounded : icon;
    final effectiveTitle = isConnection
        ? (title ?? 'errors.connection_title')
        : title;
    final effectiveMessage = isConnection ? 'errors.connection_message' : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Glowing warning medallion.
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.18),
                    colors.warningSurface.withValues(alpha: 0.55),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: 0.28),
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.22),
                    blurRadius: 28,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(effectiveIcon, size: 46, color: accent),
            ),
            if (effectiveTitle != null) ...[
              const SizedBox(height: 22),
              ResponsiveText(
                effectiveTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.textPrimary,
                ),
              ),
            ],
            SizedBox(height: effectiveTitle != null ? 8 : 20),
            ResponsiveText(
              effectiveMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                height: 1.45,
                color: colors.textSecondary,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 160, maxWidth: 240),
                child: ZaadPrimaryButton(
                  label: retryLabelKey,
                  onTap: onRetry!,
                  leadingIcon: Icons.refresh_rounded,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
