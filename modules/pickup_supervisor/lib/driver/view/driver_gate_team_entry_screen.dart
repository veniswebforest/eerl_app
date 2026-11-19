import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/driver/services/driver_photo_capture.dart';
import 'package:pickup_supervisor/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _assets = 'assets/icons/driver/location_flow';

class DriverGateTeamEntryScreen extends StatelessWidget {
  const DriverGateTeamEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _GateTeamEntryView());
  }
}

class _GateTeamEntryView extends StatefulWidget {
  const _GateTeamEntryView();

  @override
  State<_GateTeamEntryView> createState() => _GateTeamEntryViewState();
}

class _GateTeamEntryViewState extends State<_GateTeamEntryView> {
  static const _maximumPhotos = 2;
  static const _recoveryId = 'driver.pickup.gate_team';

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<XFile> _photos = [];
  bool _restoredPhoto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredPhoto) return;
    _restoredPhoto = true;
    unawaited(_restorePhoto());
  }

  Future<void> _restorePhoto() async {
    final recover = DriverPhotoCaptureScope.of(context).recover;
    if (recover == null) return;
    final photo = await recover(_recoveryId);
    if (photo != null && mounted && _photos.length < _maximumPhotos) {
      setState(() => _photos.add(photo));
    }
  }

  Future<void> _capturePhoto() async {
    if (_photos.length >= _maximumPhotos) return;
    final photo = await DriverPhotoCaptureScope.of(context).capture(
      context,
      recoveryId: _recoveryId,
      title: DriverLocalizations.of(context).capturePhoto,
    );
    if (photo != null && mounted && _photos.length < _maximumPhotos) {
      setState(() => _photos.add(photo));
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 480.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: pageWidth,
                height: constraints.maxHeight,
                child: CustomScrollView(
                  key: const Key('driver-gate-team-scroll'),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        topInset + 18,
                        20,
                        math.max(MediaQuery.paddingOf(context).bottom, 20),
                      ),
                      sliver: SliverList.list(
                        children: [
                          DriverStopsPageHeader(
                            title: l10n.gateTeamWillEnter,
                            gap: 16,
                            backAsset: '$_assets/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          const _GateStopCard(),
                          const SizedBox(height: 20),
                          Text(
                            l10n.weightYouNotedOptional,
                            style: DriverTextStyles.medium14.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _WeightField(controller: _weightController),
                          const SizedBox(height: 8),
                          Text(
                            l10n.gateWeightHelp,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: DriverTextStyles.medium12.copyWith(
                              color: DriverColors.neutral500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            l10n.photoOptional,
                            style: DriverTextStyles.medium14.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DriverCaptureArea(
                            label: l10n.capturePhoto,
                            icon: '$_assets/camera.svg',
                            iconSize: 22,
                            active: _photos.length < _maximumPhotos,
                            captureKey: const Key('driver-gate-capture-photo'),
                            onTap: _capturePhoto,
                          ),
                          if (_photos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (
                                  var index = 0;
                                  index < _photos.length;
                                  index++
                                )
                                  DriverPhotoThumbnail(
                                    filePath: _photos[index].path,
                                    removeIcon:
                                        '$driverPickupIconRoot/photo_remove.svg',
                                    onRemove: () =>
                                        setState(() => _photos.removeAt(index)),
                                    onPreview: () =>
                                        DriverPhotoPreviewDialog.show(
                                          context,
                                          _photos[index].path,
                                        ),
                                  ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 20),
                          Text(
                            l10n.noteForSupervisorOptional,
                            style: DriverTextStyles.medium14.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _GateNoteField(controller: _noteController),
                          const SizedBox(height: 8),
                          const _GateVoiceNote(),
                          const SizedBox(height: 28),
                          DriverPrimaryButton(
                            key: const Key('driver-mark-gate-team'),
                            label: l10n.markForGateTeam,
                            radius: 12,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GateStopCard extends StatelessWidget {
  const _GateStopCard();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: DriverColors.cool300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SvgPicture.asset('$_assets/gate.svg', package: _package),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.shreeSaiStopSeven,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.gateTeamEntryMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightField extends StatelessWidget {
  const _WeightField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return SizedBox(
      height: 50,
      child: TextField(
        key: const Key('driver-gate-weight'),
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,3}')),
        ],
        style: DriverTextStyles.regular14.copyWith(
          color: DriverColors.neutral950,
        ),
        decoration: InputDecoration(
          prefixText: 'KG   ',
          prefixStyle: DriverTextStyles.semibold16.copyWith(
            color: DriverColors.neutral950,
          ),
          hintText: l10n.aboutThreeHundred,
          hintStyle: DriverTextStyles.regular14.copyWith(
            color: DriverColors.cool500,
          ),
          filled: true,
          fillColor: DriverColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DriverColors.cool400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: DriverColors.primary500),
          ),
        ),
      ),
    );
  }
}

class _GateNoteField extends StatelessWidget {
  const _GateNoteField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return SizedBox(
      height: 96,
      child: TextField(
        key: const Key('driver-gate-note'),
        controller: controller,
        maxLength: 150,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [LengthLimitingTextInputFormatter(150)],
        style: DriverTextStyles.regular14.copyWith(
          color: DriverColors.neutral950,
        ),
        decoration: InputDecoration(
          hintText: l10n.typeANote,
          hintStyle: DriverTextStyles.regular14.copyWith(
            color: DriverColors.cool500,
          ),
          counterText: '',
          filled: true,
          fillColor: DriverColors.surface,
          contentPadding: const EdgeInsets.all(16),
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
    );
  }
}

class _GateVoiceNote extends StatelessWidget {
  const _GateVoiceNote();

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.cool400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: DriverColors.primary500,
              shape: BoxShape.circle,
            ),
            child: SvgPicture.asset('$_assets/mic.svg', package: _package),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.holdToRecordVoiceNote,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                Text(
                  l10n.upToOneMinute,
                  style: DriverTextStyles.medium12.copyWith(
                    color: DriverColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            l10n.voiceNoteZeroTime,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}
