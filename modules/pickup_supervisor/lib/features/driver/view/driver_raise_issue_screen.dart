import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetPackage = 'pickup_supervisor';
const _issueAssetRoot = 'assets/icons/driver/issues';

enum _DriverIssueType { vehicleBreakdown, accident, sourceProblem, other }

class DriverRaiseIssueScreen extends StatelessWidget {
  const DriverRaiseIssueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _DriverRaiseIssueView());
  }
}

class _DriverRaiseIssueView extends StatefulWidget {
  const _DriverRaiseIssueView();

  @override
  State<_DriverRaiseIssueView> createState() => _DriverRaiseIssueViewState();
}

class _DriverRaiseIssueViewState extends State<_DriverRaiseIssueView> {
  final TextEditingController _remarksController = TextEditingController();
  final Set<_DriverIssueType> _selectedIssues = {
    _DriverIssueType.vehicleBreakdown,
  };

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  void _toggleIssue(_DriverIssueType issue) {
    setState(() {
      if (!_selectedIssues.remove(issue)) _selectedIssues.add(issue);
    });
  }

  String _issueLabel(DriverLocalizations l10n, _DriverIssueType issue) {
    return switch (issue) {
      _DriverIssueType.vehicleBreakdown => l10n.vehicleBreakdown,
      _DriverIssueType.accident => l10n.accident,
      _DriverIssueType.sourceProblem => l10n.sourceProblem,
      _DriverIssueType.other => l10n.otherIssue,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final mediaPadding = MediaQuery.paddingOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 480.0);
            final topPadding = mediaPadding.top + 18;
            final bottomPadding = math.max(mediaPadding.bottom, 10.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: pageWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  key: const Key('driver-raise-issue-scroll'),
                  padding: EdgeInsets.fromLTRB(
                    20,
                    topPadding,
                    20,
                    bottomPadding,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight - topPadding - bottomPadding,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DriverStopsPageHeader(
                            title: l10n.raiseAnIssue,
                            gap: 16,
                            backAsset: '$_issueAssetRoot/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          _RequiredIssueLabel(
                            label: l10n.selectProblemsStruggling,
                          ),
                          const SizedBox(height: 8),
                          for (
                            var index = 0;
                            index < _DriverIssueType.values.length;
                            index++
                          ) ...[
                            _IssueOption(
                              key: ValueKey(
                                'driver-issue-${_DriverIssueType.values[index].name}',
                              ),
                              label: _issueLabel(
                                l10n,
                                _DriverIssueType.values[index],
                              ),
                              selected: _selectedIssues.contains(
                                _DriverIssueType.values[index],
                              ),
                              onTap: () =>
                                  _toggleIssue(_DriverIssueType.values[index]),
                            ),
                            if (index != _DriverIssueType.values.length - 1)
                              const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 24),
                          Text(
                            l10n.remarks,
                            style: DriverTextStyles.medium14.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _RemarksField(
                            controller: _remarksController,
                            hint: l10n.addYourRemarks,
                            limitLabel: l10n.max150Characters,
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              key: const Key('driver-submit-issue'),
                              onPressed: _selectedIssues.isEmpty ? null : () {},
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: DriverColors.red500,
                                disabledBackgroundColor:
                                    DriverColors.neutral400,
                                foregroundColor: DriverColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: DriverTextStyles.bold16,
                              ),
                              child: Text(l10n.submitIssue),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RequiredIssueLabel extends StatelessWidget {
  const _RequiredIssueLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      key: const Key('driver-issue-required-label'),
      TextSpan(
        children: [
          TextSpan(text: '$label '),
          const TextSpan(
            text: '*',
            style: TextStyle(color: DriverColors.red600),
          ),
        ],
      ),
      style: DriverTextStyles.medium14.copyWith(color: DriverColors.neutral950),
    );
  }
}

class _IssueOption extends StatelessWidget {
  const _IssueOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: DriverColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? DriverColors.red400 : DriverColors.cool400,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected
                        ? DriverColors.red600
                        : DriverColors.surface,
                    border: selected
                        ? null
                        : Border.all(color: DriverColors.neutral400),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: selected
                      ? SvgPicture.asset(
                          '$_issueAssetRoot/checked.svg',
                          package: _assetPackage,
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.regular14.copyWith(
                      color: DriverColors.neutral950,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RemarksField extends StatelessWidget {
  const _RemarksField({
    required this.controller,
    required this.hint,
    required this.limitLabel,
  });

  final TextEditingController controller;
  final String hint;
  final String limitLabel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 134,
      child: Stack(
        children: [
          TextField(
            key: const Key('driver-issue-remarks'),
            controller: controller,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            maxLength: 150,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: DriverTextStyles.regular14.copyWith(
              color: DriverColors.neutral950,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: DriverTextStyles.regular14.copyWith(
                color: DriverColors.cool500,
              ),
              counterText: '',
              contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              filled: true,
              fillColor: DriverColors.surface,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: DriverColors.cool400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: DriverColors.primary500),
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 8,
            child: Text(
              limitLabel,
              style: DriverTextStyles.regular12.copyWith(
                color: DriverColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
