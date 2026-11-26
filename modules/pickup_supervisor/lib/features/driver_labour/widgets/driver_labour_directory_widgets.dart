import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_common_widgets.dart';

class DriverLabourSearchField extends StatelessWidget {
  const DriverLabourSearchField({
    super.key,
    required this.hint,
    required this.controller,
    required this.onChanged,
  });

  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        border: Border.all(color: DriverColors.cool400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            DriverLabourAssets.search,
            package: DriverLabourAssets.package,
            width: 24,
            height: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              key: const Key('driver-labour-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: DriverTextStyles.regular14.copyWith(
                color: DriverColors.neutral950,
              ),
              decoration: driverLabourBareInputDecoration(
                hint: hint,
                hintColor: DriverColors.neutral500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Directory list card: name, phone chip and the open-arrow.
class DriverLabourPersonCard extends StatelessWidget {
  const DriverLabourPersonCard({
    super.key,
    required this.name,
    required this.phone,
    required this.onTap,
    this.inactive = false,
  });

  final String name;
  final String phone;
  final VoidCallback onTap;
  final bool inactive;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DriverColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [driverLabourCardShadow],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 32, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: DriverTextStyles.semibold18.copyWith(
                        color: inactive
                            ? DriverColors.neutral500
                            : DriverColors.neutral950,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: inactive
                                ? DriverColors.red50
                                : DriverColors.primary100,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: SvgPicture.asset(
                            inactive
                                ? DriverLabourAssets.deactivate
                                : DriverLabourAssets.phone,
                            package: DriverLabourAssets.package,
                            width: 20,
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: DriverTextStyles.medium14.copyWith(
                              color: inactive
                                  ? DriverColors.neutral600
                                  : DriverColors.neutral700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: SvgPicture.asset(
                  DriverLabourAssets.arrowUpRight,
                  package: DriverLabourAssets.package,
                  width: 14,
                  height: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "No Details Found" illustration, composed from the three Figma groups.
class DriverLabourEmptyState extends StatelessWidget {
  const DriverLabourEmptyState({super.key, required this.message});

  final String message;

  static const _width = 174.0;
  static const _height = 170.0;

  @override
  Widget build(BuildContext context) {
    Widget part(String asset) => SvgPicture.asset(
      asset,
      package: DriverLabourAssets.package,
      fit: BoxFit.fill,
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: .3,
            child: SizedBox(
              width: _width,
              height: _height,
              child: Stack(
                children: [
                  Positioned(
                    top: _height * .3501,
                    bottom: 0,
                    left: _width * .5803,
                    right: 0,
                    child: part(DriverLabourAssets.emptyBin),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    right: _width * .457,
                    child: part(DriverLabourAssets.emptyWorker),
                  ),
                  Positioned(
                    top: _height * .84,
                    bottom: 0,
                    left: _width * .4184,
                    right: _width * .2506,
                    child: part(DriverLabourAssets.emptyShadow),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
