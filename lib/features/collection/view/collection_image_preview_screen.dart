import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CollectionImagePreviewScreen extends StatelessWidget {
  const CollectionImagePreviewScreen({super.key, required this.imageProvider});

  final ImageProvider imageProvider;

  static Route<void> route(ImageProvider imageProvider) =>
      PageRouteBuilder<void>(
        opaque: true,
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 303, maxHeight: 381),
          child: AspectRatio(
            aspectRatio: 303 / 381,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: InkWell(
                    key: const Key('collection-image-preview-close'),
                    onTap: () => Navigator.of(context).pop(),
                    borderRadius: BorderRadius.circular(6),
                    child: SvgPicture.asset(
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
  );
}
