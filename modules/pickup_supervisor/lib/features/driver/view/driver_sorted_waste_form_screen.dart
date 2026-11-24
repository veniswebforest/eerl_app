import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/service/driver_photo_capture.dart';
import 'package:pickup_supervisor/features/driver/view/driver_pickup_success_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_voice_note_recorder.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

class DriverSortedWasteFormScreen extends StatelessWidget {
  const DriverSortedWasteFormScreen({super.key, this.locationMatched = true});

  final bool locationMatched;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: _SortedWasteFormView(locationMatched: locationMatched),
    );
  }
}

class _SortedWasteFormView extends StatefulWidget {
  const _SortedWasteFormView({required this.locationMatched});

  final bool locationMatched;

  @override
  State<_SortedWasteFormView> createState() => _SortedWasteFormViewState();
}

class _SortedWasteFormViewState extends State<_SortedWasteFormView> {
  static const _maximumPhotos = 2;
  final List<List<XFile>> _photos = List.generate(3, (_) => <XFile>[]);
  final List<TextEditingController> _collectedControllers = List.generate(
    3,
    (_) => TextEditingController(),
  );
  final TextEditingController _noteController = TextEditingController();
  bool _restoredPhotos = false;

  bool get _canSave =>
      _photos.every((photos) => photos.isNotEmpty) &&
      _collectedControllers.every(
        (controller) => controller.text.trim().isNotEmpty,
      );

  @override
  void initState() {
    super.initState();
    for (final controller in _collectedControllers) {
      controller.addListener(_refreshForm);
    }
  }

  void _refreshForm() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_restoredPhotos) return;
    _restoredPhotos = true;
    unawaited(_restorePhotos());
  }

  Future<void> _restorePhotos() async {
    final recover = DriverPhotoCaptureScope.of(context).recover;
    if (recover == null) return;
    for (var index = 0; index < _photos.length; index++) {
      final photo = await recover(_recoveryId(index));
      if (photo != null && mounted && _photos[index].length < _maximumPhotos) {
        setState(() {
          _photos[index].add(photo);
          _applyMockCollectedValue(index);
        });
      }
    }
  }

  Future<void> _capturePhoto({
    required int index,
    required String title,
  }) async {
    if (_photos[index].length >= _maximumPhotos) return;
    final photo = await DriverPhotoCaptureScope.of(
      context,
    ).capture(context, recoveryId: _recoveryId(index), title: title);
    if (photo == null || !mounted) return;
    setState(() {
      if (_photos[index].length < _maximumPhotos) {
        _photos[index].add(photo);
        _applyMockCollectedValue(index);
      }
    });
  }

  void _applyMockCollectedValue(int index) {
    if (_collectedControllers[index].text.isNotEmpty) return;
    _collectedControllers[index].text = index == 2 ? '25' : '270.00';
  }

  @override
  void dispose() {
    for (final controller in _collectedControllers) {
      controller
        ..removeListener(_refreshForm)
        ..dispose();
    }
    _noteController.dispose();
    super.dispose();
  }

  String _recoveryId(int index) => 'driver.pickup.sorted.$index';

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    final materials = [
      _SortedMaterialData(
        name: l10n.petBottles,
        unit: l10n.kgUnit,
        emptyImage: '$driverPickupImageRoot/pet_empty.png',
        filledImage: '$driverPickupImageRoot/pet_filled.png',
        allowDecimal: true,
      ),
      _SortedMaterialData(
        name: l10n.hdpeRigid,
        unit: l10n.kgUnit,
        emptyImage: '$driverPickupImageRoot/hdpe_empty.png',
        filledImage: '$driverPickupImageRoot/hdpe_filled.png',
        allowDecimal: true,
      ),
      _SortedMaterialData(
        name: l10n.eWaste,
        unit: l10n.pcsUnit,
        emptyImage: '$driverPickupImageRoot/ewaste_empty.png',
        filledImage: '$driverPickupImageRoot/ewaste_filled.png',
        allowDecimal: false,
      ),
    ];

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
                  key: const Key('driver-sorted-form'),
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
                            title: l10n.sortedWasteForm,
                            gap: 16,
                            backAsset: '$driverPickupIconRoot/sorted_back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          DriverPickupStopSummary(
                            title: l10n.abcTextileMills,
                            subtitle: l10n.sortedStopSixOfSeven,
                            locationLabel: widget.locationMatched
                                ? l10n.locationMatched
                                : l10n.locationNotMatched,
                            locationMatched: widget.locationMatched,
                          ),
                          if (!widget.locationMatched) ...[
                            const SizedBox(height: 16),
                            DriverLocationMismatchNotice(
                              message: l10n.recordedLaterWarning,
                            ),
                          ],
                          const SizedBox(height: 32),
                          Text(
                            l10n.captureMaterialScalePhoto,
                            style: DriverTextStyles.semibold14.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (
                            var index = 0;
                            index < materials.length;
                            index++
                          ) ...[
                            _SortedMaterialCard(
                              data: materials[index],
                              controller: _collectedControllers[index],
                              photos: _photos[index],
                              collectedLabel: l10n.collectedLabel,
                              placeholder: l10n.exampleWeight,
                              captureLabel: l10n.capturePhoto,
                              captureKey: Key('driver-capture-photo-$index'),
                              onCapture: () => _capturePhoto(
                                index: index,
                                title:
                                    '${l10n.capturePhoto} - ${materials[index].name}',
                              ),
                              onRemove: (photoIndex) => setState(
                                () => _photos[index].removeAt(photoIndex),
                              ),
                            ),
                            if (index != materials.length - 1)
                              const SizedBox(height: 16),
                          ],
                          const SizedBox(height: 32),
                          Text(
                            l10n.noteForSupervisorOptional,
                            style: DriverTextStyles.medium14.copyWith(
                              color: DriverColors.neutral950,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DriverSupervisorNoteField(
                            controller: _noteController,
                            hint: l10n.typeANote,
                            limitLabel: l10n.max150Characters,
                          ),
                          const SizedBox(height: 8),
                          const DriverVoiceNoteRecorder(),
                          const SizedBox(height: 24),
                          DriverFormButton(
                            label: l10n.savePickup,
                            enabled: _canSave,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const DriverPickupSuccessScreen(),
                              ),
                            ),
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

class _SortedMaterialData {
  const _SortedMaterialData({
    required this.name,
    required this.unit,
    required this.emptyImage,
    required this.filledImage,
    required this.allowDecimal,
  });

  final String name;
  final String unit;
  final String emptyImage;
  final String filledImage;
  final bool allowDecimal;
}

class _SortedMaterialCard extends StatelessWidget {
  const _SortedMaterialCard({
    required this.data,
    required this.controller,
    required this.photos,
    required this.collectedLabel,
    required this.placeholder,
    required this.captureLabel,
    required this.captureKey,
    required this.onCapture,
    required this.onRemove,
  });

  final _SortedMaterialData data;
  final TextEditingController controller;
  final List<XFile> photos;
  final String collectedLabel;
  final String placeholder;
  final String captureLabel;
  final Key captureKey;
  final VoidCallback onCapture;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    final isFilled = photos.isNotEmpty;
    final canCapture = photos.length < _SortedWasteFormViewState._maximumPhotos;
    return Container(
      decoration: BoxDecoration(
        color: DriverColors.surface,
        border: Border.all(color: DriverColors.cool400),
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: DriverColors.cool200,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.asset(
                    isFilled ? data.filledImage : data.emptyImage,
                    package: driverAssetPackage,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    '${data.name}  •  ${data.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: DriverTextStyles.semibold14.copyWith(
                      color: DriverColors.cool950,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DriverRequiredLabel(label: collectedLabel),
                const SizedBox(height: 8),
                DriverEditableValueField(
                  controller: controller,
                  prefix: data.unit,
                  placeholder: placeholder,
                  allowDecimal: data.allowDecimal,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 1,
                  child: SvgPicture.asset(
                    '$driverPickupIconRoot/sorted_divider.svg',
                    package: driverAssetPackage,
                    fit: BoxFit.fill,
                  ),
                ),
                const SizedBox(height: 16),
                DriverCaptureArea(
                  captureKey: captureKey,
                  label: captureLabel,
                  icon: canCapture
                      ? '$driverPickupIconRoot/camera.svg'
                      : '$driverPickupIconRoot/camera_disabled.svg',
                  active: canCapture,
                  onTap: onCapture,
                ),
                if (photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      for (var index = 0; index < photos.length; index++) ...[
                        DriverPhotoThumbnail(
                          key: ValueKey(photos[index].path),
                          filePath: photos[index].path,
                          removeIcon: '$driverPickupIconRoot/photo_remove.svg',
                          onPreview: () => DriverPhotoPreviewDialog.show(
                            context,
                            photos[index].path,
                          ),
                          onRemove: () => onRemove(index),
                        ),
                        if (index < photos.length - 1)
                          const SizedBox(width: 12),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
