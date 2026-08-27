import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:eerl_app/core/theme/app_colors.dart';
import 'package:eerl_app/core/theme/app_text_styles.dart';
import '../model/transfer_request_item.dart';

class TransferRequestFilterBar extends StatelessWidget {
  const TransferRequestFilterBar({
    super.key,
    required this.searchHint,
    required this.searchController,
    required this.selectedFilter,
    required this.labels,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final String searchHint;
  final TextEditingController searchController;
  final TransferRequestFilter selectedFilter;
  final Map<TransferRequestFilter, String> labels;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<TransferRequestFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SizedBox(
        height: 52,
        child: TextField(
          key: const Key('transfer-request-search'),
          controller: searchController,
          onChanged: onSearchChanged,
          style: AppTextStyles.regularB7_14,
          decoration: InputDecoration(
            hintText: searchHint,
            hintStyle: AppTextStyles.regularB7_14.copyWith(
              color: AppColors.neutral400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(15),
              child: SvgPicture.asset(
                'assets/icons/wallet/search.svg',
                width: 20,
                height: 20,
              ),
            ),
            filled: true,
            fillColor: AppColors.neutral50,
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.cool400),
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: AppColors.primary500),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),
      SingleChildScrollView(
        child: Row(
          children: TransferRequestFilter.values
              .map((filter) {
                final selected = filter == selectedFilter;
                return Padding(
                  padding: EdgeInsets.only(
                    right: filter == TransferRequestFilter.closed ? 0 : 6,
                  ),
                  child: Material(
                    color: selected ? AppColors.primary500 : AppColors.cool200,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      key: Key('transfer-filter-${filter.name}'),
                      onTap: () => onFilterChanged(filter),
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        height: 34,
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Center(
                          child: Text(
                            labels[filter]!,
                            style: AppTextStyles.mediumSH8_14.copyWith(
                              color: selected
                                  ? AppColors.neutral50
                                  : AppColors.neutral700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              })
              .toList(growable: false),
        ),
      ),
    ],
  );
}
