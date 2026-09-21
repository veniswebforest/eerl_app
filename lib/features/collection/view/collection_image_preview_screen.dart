import 'dart:ui';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CollectionImagePreviewScreen extends StatelessWidget {
  const CollectionImagePreviewScreen({super.key, required this.imageProvider});

  final ImageProvider imageProvider;

  static Route<void> route(ImageProvider imageProvider) =>
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: AppColors.neutral950.withValues(alpha: 0.9),
        pageBuilder: (context, animation, secondaryAnimation) =>
            CollectionImagePreviewScreen(imageProvider: imageProvider),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              ),
              child: child,
            ),
        transitionDuration: const Duration(milliseconds: 180),
        reverseTransitionDuration: const Duration(milliseconds: 140),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const Key('collection-image-preview-screen'),
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),

            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 303, maxHeight: 381),
              child: AspectRatio(
                aspectRatio: 303 / 381,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      InteractiveViewer(
                        minScale: 1,
                        maxScale: 4,
                        child: Image(image: imageProvider, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: IconButton(
                          key: const Key('collection-image-preview-close'),
                          tooltip: MaterialLocalizations.of(
                            context,
                          ).closeButtonTooltip,
                          onPressed: () => Navigator.of(context).pop(),
                          icon: SvgPicture.asset(
                            'assets/icons/wallet/expense_remove.svg',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
