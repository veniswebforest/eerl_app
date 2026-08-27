import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/extensions/context_extensions.dart';
import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/request_list_item.dart';

class RequestListCard extends StatelessWidget {
  const RequestListCard({
    super.key,
    required this.item,
    required this.description,
    this.onTap,
  });

  final RequestListItem item;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.cool100),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x16000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.requestSupervisorName,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.semiboldH9_14.copyWith(
                    color: AppColors.neutral950,
                  ),
                ),
              ),
              SvgPicture.asset(
                'assets/icons/wallet/open_details.svg',
                width: 18,
                height: 18,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.cool100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.regularB8_12.copyWith(
                color: AppColors.neutral700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.attach_file_rounded,
                size: 17,
                color: AppColors.neutral600,
              ),
              const SizedBox(width: 4),
              Text(
                context.l10n.requestPhotoAttached,
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _RequestStatusChip(status: item.status)),
              const SizedBox(width: 8),
              Text(
                context.l10n.requestTodayTime(item.time),
                style: AppTextStyles.regularB8_12.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

class _RequestStatusChip extends StatelessWidget {
  const _RequestStatusChip({required this.status});

  final RequestListStatus status;

  @override
  Widget build(BuildContext context) {
    final closed = status == RequestListStatus.closed;
    final foreground = closed ? AppColors.primary500 : AppColors.yellow600;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        closed
            ? SvgPicture.asset(
                'assets/icons/wallet/status_verified.svg',
                width: 16,
                height: 16,
              )
            : SvgPicture.asset(
                'assets/icons/records/status_pending.svg',
                width: 16,
                height: 16,
              ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            closed
                ? context.l10n.requestClosedBySupervisor
                : context.l10n.requestAwaitingResponse,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.mediumSH9_12.copyWith(color: foreground),
          ),
        ),
      ],
    );
  }
}
