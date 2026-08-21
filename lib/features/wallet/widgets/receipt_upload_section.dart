import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import 'wallet_assets.dart';

class ReceiptUploadSection extends StatelessWidget {
  const ReceiptUploadSection({
    super.key,
    required this.captureLabel,
    required this.helperText,
    required this.hasReceipts,
    required this.onCapture,
    required this.onRemove,
  });

  final String captureLabel;
  final String helperText;
  final bool hasReceipts;
  final VoidCallback onCapture;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: const Key('capture-receipt-button'),
          onTap: onCapture,
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
              Expanded(child: _ReceiptPreview(onRemove: onRemove)),
              const SizedBox(width: 8),
              Expanded(child: _ReceiptPreview(onRemove: onRemove)),
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
  const _ReceiptPreview({required this.onRemove});

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
            child: Image.asset(
              'assets/images/expense_receipt.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            right: 6,
            top: 6,
            child: InkWell(
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
