import 'package:eerl_app/core/providers/network_provider.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/app_message_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Wraps the application layout to present a top side view overlay banner
/// whenever realtime network connectivity status changes (Offline / Restored).
class NetworkStatusOverlay extends StatelessWidget {
  const NetworkStatusOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<NetworkProvider>(
          builder: (context, network, _) {
            final isOffline = network.isOffline;
            final showRestored = network.showRestoredBanner;
            final shouldShow = network.shouldShowBanner;

            final topPadding = MediaQuery.of(context).padding.top;

            return AnimatedPositioned(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              top: shouldShow ? topPadding + 10 : -(topPadding + 90),
              left: 16,
              right: 16,
              child: Material(
                type: MaterialType.transparency,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: shouldShow
                      ? _buildBannerContent(
                          context,
                          isOffline: isOffline,
                          showRestored: showRestored,
                          onDismiss: network.dismissBanner,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBannerContent(
    BuildContext context, {
    required bool isOffline,
    required bool showRestored,
    required VoidCallback onDismiss,
  }) {
    final isRestored = !isOffline && showRestored;

    final gradientColors = isRestored
        ? const [AppColors.primary600, AppColors.primary800]
        : const [AppColors.red600, Color(0xFF991B1B)];

    final iconData = isRestored ? Icons.wifi_rounded : Icons.wifi_off_rounded;

    final titleText = isRestored ? 'Back Online' : 'No Internet Connection';

    final subtitleText = isRestored
        ? 'Internet connection restored.'
        : 'Please check your Wi-Fi or mobile data network.';

    return AppMessageBanner(
      key: ValueKey(isRestored ? 'online_banner' : 'offline_banner'),
      title: titleText,
      subtitle: subtitleText,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      gradient: LinearGradient(
        colors: gradientColors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.white.withValues(alpha: 0.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      titleStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      subtitleStyle: TextStyle(
        color: Colors.white.withValues(alpha: 0.9),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      subtitleMaxLines: 2,
      iconBackgroundColor: Colors.white.withValues(alpha: 0.18),
      iconPadding: const EdgeInsets.all(8),
      icon: Icon(iconData, color: Colors.white, size: 22),
      closeIcon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
      ),
      onClose: onDismiss,
    );
  }
}
