import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Pending collection drafts section with a "View All" link and draft card.
class CollectionDrafts extends StatelessWidget {
  const CollectionDrafts({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Collection Drafts',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A202C),
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary500,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'View All',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Draft card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE6EBEE), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Submission tag
              Container(
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2C6),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFFFBF29),
                    width: 0.5,
                  ),
                ),
                child: const Text(
                  'Pending Submission',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF9AE00),
                  ),
                ),
              ),

              // Draft title
              const Padding(
                padding: EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: Text(
                  'MRF Station Aanjana',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A202C),
                  ),
                ),
              ),

              // Location row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 0),
                child: Row(
                  children: const [
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Color(0xFF92A3B0),
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Lidhna, Sardar Market, Surat',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92A3B0),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Image row
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
                child: Row(
                  children: const [
                    Icon(
                      Icons.image_outlined,
                      size: 14,
                      color: Color(0xFF92A3B0),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '...',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92A3B0)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Continue Collection button
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Continue Collection'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
