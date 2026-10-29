import 'package:eerl_app/shared/widgets/cached_app_image.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'package:flutter/material.dart';

class TaskPhotoGrid extends StatelessWidget {
  const TaskPhotoGrid({
    super.key,
    required this.images,
    this.removable = false,
    this.onRemove,
  });

  final List<String> images;
  final bool removable;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      const spacing = 8.0;
      final itemWidth = (constraints.maxWidth - spacing) / 2;
      return Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (var index = 0; index < images.length; index++)
            SizedBox(
              width: itemWidth,
              height: 92,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: SizedBox.expand(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          key: ValueKey('preview-task-photo-$index'),
                          onTap: () => AppImagePreviewDialog.showSource(
                            context,
                            images[index],
                          ),
                          child: _TaskImage(path: images[index]),
                        ),
                      ),
                    ),
                  ),
                  if (removable)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: InkWell(
                        key: ValueKey('remove-task-proof-$index'),
                        onTap: () => onRemove?.call(index),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.close, size: 17),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class _TaskImage extends StatelessWidget {
  const _TaskImage({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) =>
      CachedAppImage(source: path, fit: BoxFit.cover);
}
