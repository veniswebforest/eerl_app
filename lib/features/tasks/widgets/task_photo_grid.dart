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
  Widget build(BuildContext context) => Row(
    children: [
      for (var index = 0; index < images.length; index++) ...[
        if (index > 0) const SizedBox(width: 10),
        Expanded(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 1.85,
                  child: Image.asset(images[index], fit: BoxFit.cover),
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
    ],
  );
}
