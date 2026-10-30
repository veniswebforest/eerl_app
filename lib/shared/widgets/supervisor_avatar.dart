import 'package:flutter/material.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/shared/widgets/cached_app_image.dart';

/// Renders a circular supervisor avatar displaying the remote/cached photo,
/// or a circular container with their initials if the photo is missing,
/// offline before being cached, or fails to load.
class SupervisorAvatar extends StatelessWidget {
  const SupervisorAvatar({
    super.key,
    this.name,
    this.photoUrl,
    this.size = 40,
    this.backgroundColor = AppColors.primary100,
    this.textColor = AppColors.primary500,
  });

  final String? name;
  final String? photoUrl;
  final double size;
  final Color backgroundColor;
  final Color textColor;

  static String initials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length > 1) {
      return '${parts.first.characters.first}${parts.last.characters.first}'
          .toUpperCase();
    }
    return parts.first.characters.first.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final initialsText = initials(name);
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initialsText,
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );

    final cleanUrl = photoUrl?.trim();
    if (cleanUrl == null || cleanUrl.isEmpty) {
      return placeholder;
    }

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: CachedAppImage(
          source: cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: placeholder,
        ),
      ),
    );
  }
}
