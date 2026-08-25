import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'app_screen_header.dart';

/// A reusable custom [AppBar] built using the design spec.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.actions,
    this.onBackTap,
    this.backIconAsset,
  });

  final String? title;
  final bool showBackButton;
  final List<Widget>? actions;
  final VoidCallback? onBackTap;
  final String? backIconAsset;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: AppScreenHeaderMetrics.height,
      leadingWidth: 60,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: context.palette.textPrimary,
              ),
            )
          : null,
      leading: showBackButton
          ? Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: onBackTap ?? () => context.pop(),
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: context.palette.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: backIconAsset == null
                        ? const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 20,
                          )
                        : SvgPicture.asset(
                            backIconAsset!,
                            width: 20,
                            height: 20,
                          ),
                  ),
                ),
              ),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(AppScreenHeaderMetrics.height);
}
