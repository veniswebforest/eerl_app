import 'dart:io';

import 'package:eerl_app/core/providers/network_provider.dart';
import 'package:eerl_app/features/bootstrap/service/item_image_cache_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays local and bundled images directly. Remote images use the network
/// while online and the persistent app image cache while offline.
class CachedAppImage extends StatelessWidget {
  const CachedAppImage({
    super.key,
    required this.source,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  final String? source;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final path = source?.trim() ?? '';
    if (path.isEmpty) return _placeholder();
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }
    if (!_isRemote(path)) {
      return Image.file(
        File(path),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    final isOffline = context.watch<NetworkProvider?>()?.isOffline ?? false;
    if (!isOffline) {
      return FutureBuilder<File?>(
        future: ItemImageCacheService.instance.cacheFileForUrl(path),
        builder: (context, snapshot) {
          final fallback = _fileOrPlaceholder(snapshot.data);
          return Image.network(
            path,
            width: width,
            height: height,
            fit: fit,
            gaplessPlayback: true,
            loadingBuilder: (context, child, progress) =>
                progress == null ? child : fallback,
            errorBuilder: (_, _, _) => fallback,
          );
        },
      );
    }
    return _cachedFile(path);
  }

  Widget _cachedFile(String url) {
    return FutureBuilder<File?>(
      future: ItemImageCacheService.instance.localFileForUrl(url),
      builder: (context, snapshot) => _fileOrPlaceholder(snapshot.data),
    );
  }

  Widget _fileOrPlaceholder(File? cached) {
    if (cached == null) return _placeholder();
    return Image.file(
      cached,
      width: width,
      height: height,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  Widget _placeholder() => SizedBox(
    width: width,
    height: height,
    child:
        placeholder ??
        const ColoredBox(
          color: Color(0xFFE5E7EB),
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
  );

  static bool _isRemote(String path) {
    final uri = Uri.tryParse(path);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
