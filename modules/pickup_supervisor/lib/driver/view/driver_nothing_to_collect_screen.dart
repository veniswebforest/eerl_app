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
const _assets = 'assets/icons/driver/stop_detail_v2';

enum _NothingReason {
  closed,
  noMaterial,
  refused,
  notReachable,
  vehicleFull,
  other,
}

class DriverNothingToCollectScreen extends StatelessWidget {
  const DriverNothingToCollectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DriverLocalizationScope(child: _NothingToCollectView());
  }
}

class _NothingToCollectView extends StatefulWidget {
  const _NothingToCollectView();

  @override
  State<_NothingToCollectView> createState() => _NothingToCollectViewState();
}

class _NothingToCollectViewState extends State<_NothingToCollectView> {
  static const _maximumPhotos = 2;
  static const _recoveryId = 'driver.pickup.nothing_to_collect';

  final TextEditingController _noteController = TextEditingController();
  final List<XFile> _photos = [];
  _NothingReason _reason = _NothingReason.noMaterial;
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
    final l10n = DriverLocalizations.of(context);
    final photo = await DriverPhotoCaptureScope.of(
      context,
    ).capture(context, recoveryId: _recoveryId, title: l10n.capturePhoto);
    if (photo != null && mounted && _photos.length < _maximumPhotos) {
      setState(() => _photos.add(photo));
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _reasonLabel(DriverLocalizations l10n, _NothingReason reason) {
    return switch (reason) {
      _NothingReason.closed => l10n.reasonClosed,
      _NothingReason.noMaterial => l10n.noMaterialToday,
      _NothingReason.refused => l10n.reasonRefused,
      _NothingReason.notReachable => l10n.reasonNotReachable,
      _NothingReason.vehicleFull => l10n.reasonVehicleFull,
      _NothingReason.other => l10n.otherIssue,
    };
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
                  key: const Key('driver-nothing-collect-scroll'),
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
                            title: l10n.nothingToCollect,
                            gap: 16,
                            backAsset: '$_assets/nothing_back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          const _ZeroKgStopCard(),
                          const SizedBox(height: 20),
                          _RequiredLabel(
                            key: const Key('driver-zero-reason-label'),
                            label: l10n.whyNothingCollected,
                          ),
                          const SizedBox(height: 8),
                          for (
                            var index = 0;
                            index < _NothingReason.values.length;
                            index++
                          ) ...[
                            _ReasonOption(
                              key: ValueKey(
                                'driver-zero-reason-${_NothingReason.values[index].name}',
                              ),
                              label: _reasonLabel(
                                l10n,
                                _NothingReason.values[index],
                              ),
                              selected: _reason == _NothingReason.values[index],
                              onTap: () => setState(
                                () => _reason = _NothingReason.values[index],
                              ),
                            ),
                            if (index != _NothingReason.values.length - 1)
                              const SizedBox(height: 8),
                          ],
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
                            active: _photos.length < _maximumPhotos,
                            captureKey: const Key('driver-zero-capture-photo'),
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
                          _NoteField(
                            controller: _noteController,
                            hint: l10n.typeANote,
                            limit: l10n.max150Characters,
                          ),
                          const SizedBox(height: 8),
                          const _VoiceNoteRow(),
                          const SizedBox(height: 28),
                          DriverPrimaryButton(
                            label: l10n.saveAsZeroKg,
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

class _ZeroKgStopCard extends StatelessWidget {
  const _ZeroKgStopCard();

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
            child: SvgPicture.asset(
              '$_assets/nothing_scale.svg',
              package: _package,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.abcStopSixOfSeven,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.savedAsZeroKgMessage,
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

class _ReasonOption extends StatelessWidget {
  const _ReasonOption({
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
    color: selected ? DriverColors.primary50 : DriverColors.surface,
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
        height: 50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              SvgPicture.asset(
                selected ? '$_assets/radio_selected.svg' : '$_assets/radio.svg',
                package: _package,
                width: 20,
                height: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (selected
                              ? DriverTextStyles.semibold14
                              : DriverTextStyles.medium14)
                          .copyWith(color: DriverColors.neutral950),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _NoteField extends StatelessWidget {
  const _NoteField({
    required this.controller,
    required this.hint,
    required this.limit,
  });
  final TextEditingController controller;
  final String hint;
  final String limit;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 96,
    child: Stack(
      children: [
        TextField(
          key: const Key('driver-zero-note'),
          controller: controller,
          expands: true,
          maxLines: null,
          maxLength: 150,
          maxLengthEnforcement: MaxLengthEnforcement.enforced,
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
            contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
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
            limit,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral400,
            ),
          ),
        ),
      ],
    ),
  );
}

class _VoiceNoteRow extends StatelessWidget {
  const _VoiceNoteRow();

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
