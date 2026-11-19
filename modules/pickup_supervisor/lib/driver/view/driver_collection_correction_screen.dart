import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/view/driver_correction_request_sent_screen.dart';
import 'package:pickup_supervisor/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _assets = 'assets/icons/driver/correction';

enum _CorrectionType { weight, item, photo, other }

class DriverCollectionCorrectionScreen extends StatelessWidget {
  const DriverCollectionCorrectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _CollectionCorrectionView());
  }
}

class _CollectionCorrectionView extends StatefulWidget {
  const _CollectionCorrectionView();

  @override
  State<_CollectionCorrectionView> createState() =>
      _CollectionCorrectionViewState();
}

class _CollectionCorrectionViewState extends State<_CollectionCorrectionView> {
  final TextEditingController _noteController = TextEditingController();
  final Set<_CorrectionType> _selected = {_CorrectionType.weight};

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _toggle(_CorrectionType type) {
    setState(() {
      if (!_selected.remove(type)) _selected.add(type);
    });
  }

  String _label(DriverLocalizations l10n, _CorrectionType type) {
    return switch (type) {
      _CorrectionType.weight => l10n.correctionWeight,
      _CorrectionType.item => l10n.correctionItem,
      _CorrectionType.photo => l10n.correctionPhoto,
      _CorrectionType.other => l10n.correctionOther,
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
                  key: const Key('driver-collection-correction-scroll'),
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
                            title: l10n.askToCorrect,
                            gap: 16,
                            backAsset: '$_assets/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          _RequiredLabel(
                            key: const Key('driver-correction-problem-label'),
                            label: l10n.whatIsWrongAtStop,
                          ),
                          const SizedBox(height: 8),
                          for (
                            var index = 0;
                            index < _CorrectionType.values.length;
                            index++
                          ) ...[
                            _CorrectionOption(
                              key: ValueKey(
                                'driver-correction-${_CorrectionType.values[index].name}',
                              ),
                              label: _label(
                                l10n,
                                _CorrectionType.values[index],
                              ),
                              selected: _selected.contains(
                                _CorrectionType.values[index],
                              ),
                              onTap: () =>
                                  _toggle(_CorrectionType.values[index]),
                            ),
                            if (index != _CorrectionType.values.length - 1)
                              const SizedBox(height: 8),
                          ],
                          const SizedBox(height: 24),
                          _RequiredLabel(
                            key: const Key('driver-correction-note-label'),
                            label: l10n.rightValueAndNote,
                          ),
                          const SizedBox(height: 8),
                          _CorrectionNoteField(
                            controller: _noteController,
                            hint: l10n.correctionNoteExample,
                            limitLabel: l10n.max150Characters,
                          ),
                          const Spacer(),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: FilledButton(
                              key: const Key('driver-send-correction'),
                              onPressed: () =>
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute<void>(
                                      builder: (_) =>
                                          const DriverCorrectionRequestSentScreen(),
                                    ),
                                  ),
                              style: FilledButton.styleFrom(
                                padding: EdgeInsets.zero,
                                backgroundColor: DriverColors.primary500,
                                foregroundColor: DriverColors.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                textStyle: DriverTextStyles.bold16,
                              ),
                              child: Text(l10n.sendToSupervisor),
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

class _RequiredLabel extends StatelessWidget {
  const _RequiredLabel({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Text.rich(
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

class _CorrectionOption extends StatelessWidget {
  const _CorrectionOption({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: DriverColors.surface,
    shape: RoundedRectangleBorder(
      side: BorderSide(
        color: selected ? DriverColors.primary500 : DriverColors.cool400,
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
                      ? DriverColors.primary500
                      : DriverColors.surface,
                  border: selected
                      ? null
                      : Border.all(color: DriverColors.neutral400),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: selected
                    ? SvgPicture.asset(
                        '$_assets/checked.svg',
                        package: _package,
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

class _CorrectionNoteField extends StatelessWidget {
  const _CorrectionNoteField({
    required this.controller,
    required this.hint,
    required this.limitLabel,
  });
  final TextEditingController controller;
  final String hint;
  final String limitLabel;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 135,
    child: Stack(
      children: [
        TextField(
          key: const Key('driver-correction-note'),
          controller: controller,
          maxLines: null,
          expands: true,
          maxLength: 150,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
          textAlignVertical: TextAlignVertical.top,
          style: DriverTextStyles.regular14.copyWith(
            color: DriverColors.neutral950,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintMaxLines: 3,
            hintStyle: DriverTextStyles.regular14.copyWith(
              color: DriverColors.cool500,
            ),
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 34),
            counterText: '',
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DriverColors.cool400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: DriverColors.primary500),
            ),
            filled: true,
            fillColor: DriverColors.surface,
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
