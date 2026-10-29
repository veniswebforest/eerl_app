import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'package:eerl_app/shared/widgets/app_image_preview_dialog.dart';
import 'wallet_assets.dart';

class ReceiptUploadSection extends StatelessWidget {
  const ReceiptUploadSection({
    super.key,
    required this.captureLabel,
    required this.helperText,
    required this.receiptPaths,
    required this.onCapture,
    required this.onRemove,
  });

  final String captureLabel;
  final String helperText;
  final List<String> receiptPaths;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;

  bool get hasReceipts => receiptPaths.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: const Key('capture-receipt-button'),
          onTap: receiptPaths.length < 2 ? onCapture : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 115,
            width: double.infinity,
            decoration: BoxDecoration(
              color: hasReceipts ? AppColors.cool100 : AppColors.primary50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomPaint(
              foregroundPainter: _DashedBorderPainter(
                color: hasReceipts ? AppColors.cool400 : AppColors.primary500,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    WalletAssets.expenseCamera,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      hasReceipts ? AppColors.cool400 : AppColors.primary500,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    captureLabel,
                    style: AppTextStyles.semiboldH9_14.copyWith(
                      color: hasReceipts
                          ? AppColors.neutral400
                          : AppColors.neutral900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hasReceipts) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              for (var index = 0; index < receiptPaths.length; index++) ...[
                Expanded(
                  child: _ReceiptPreview(
                    path: receiptPaths[index],
                    index: index,
                    onRemove: () => onRemove(index),
                  ),
                ),
                if (index != receiptPaths.length - 1) const SizedBox(width: 8),
              ],
              if (receiptPaths.length == 1) const Expanded(child: SizedBox()),
            ],
          ),
        ],
        const SizedBox(height: 12),
        Text(
          helperText,
          style: AppTextStyles.regularB8_12.copyWith(
            color: AppColors.neutral600,
          ),
        ),
      ],
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(8)),
      );
    final metric = path.computeMetrics().first;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const dash = 4.0;
    const gap = 4.0;
    for (double offset = 0; offset < metric.length; offset += dash + gap) {
      canvas.drawPath(
        metric.extractPath(offset, (offset + dash).clamp(0, metric.length)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ReceiptPreview extends StatelessWidget {
  const _ReceiptPreview({
    required this.path,
    required this.index,
    required this.onRemove,
  });

  final String path;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 143.5 / 92,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Material(
              color: AppColors.cool100,
              child: InkWell(
                key: ValueKey('preview-expense-receipt-$index'),
                onTap: () => AppImagePreviewDialog.showSource(context, path),
                child: Image.file(
                  File(path),
                  key: ValueKey('expense-receipt-image-$index'),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const ColoredBox(
                    color: AppColors.cool100,
                    child: Center(
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: AppColors.neutral400,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: InkWell(
              key: ValueKey('remove-expense-receipt-$index'),
              onTap: onRemove,
              child: SvgPicture.asset(
                WalletAssets.expenseRemove,
                width: 24,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
