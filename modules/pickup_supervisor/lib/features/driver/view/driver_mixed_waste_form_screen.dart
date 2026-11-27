import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:eerl_app/features/outbound/data/outbound_writes.dart';
import 'package:pickup_supervisor/features/driver/data/driver_stop_entry.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/service/driver_photo_capture.dart';
import 'package:pickup_supervisor/features/driver/view/driver_pickup_success_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_voice_note_recorder.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

class DriverMixedWasteFormScreen extends StatelessWidget {
  const DriverMixedWasteFormScreen({super.key, this.target});

  /// The live stop; null shows the design preview.
  final DriverStopTarget? target;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(child: _MixedWasteFormView(target: target));
  }
}

class _MixedWasteFormView extends StatefulWidget {
  const _MixedWasteFormView({this.target});

  final DriverStopTarget? target;

  @override
  State<_MixedWasteFormView> createState() => _MixedWasteFormViewState();
}

class _MixedWasteFormViewState extends State<_MixedWasteFormView> {
  static const _maximumPhotos = 2;
  static const _recoveryId = 'driver.pickup.mixed';
  final List<XFile> _photos = [];
  late final TextEditingController _weightController = TextEditingController(
    text: widget.target == null ? '300.00' : '',
  );
  bool _saving = false;

  /// Saves a Collected Mixed entry: one weight in KG.
  Future<void> _saveLive(DriverStopTarget target) async {
    setState(() => _saving = true);
    final saved = await recordDriverStop(
      context,
      target: target,
      outcome: StopOutcome.collected,
      totalKg: double.parse(_weightController.text.trim()),
      photoPaths: [for (final photo in _photos) photo.path],
      note: _noteController.text,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (!saved) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => DriverPickupSuccessScreen(
          isLastStop: target.isLastOpen,
          tripId: target.tripId,
        ),
      ),
    );
  }

  final TextEditingController _noteController = TextEditingController();
  bool _restoredPhoto = false;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_refreshForm);
  }

  void _refreshForm() {
    if (mounted) setState(() {});
  }

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
    if (photo == null || !mounted || _photos.length >= _maximumPhotos) return;
    setState(() => _photos.add(photo));
  }

  Future<void> _capturePhoto(String title) async {
    if (_photos.length >= _maximumPhotos) return;
    final photo = await DriverPhotoCaptureScope.of(
      context,
    ).capture(context, recoveryId: _recoveryId, title: title);
    if (photo == null || !mounted) return;
    setState(() {
      if (_photos.length < _maximumPhotos) _photos.add(photo);
    });
  }

  @override
  void dispose() {
    _weightController
      ..removeListener(_refreshForm)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final mediaPadding = MediaQuery.paddingOf(context);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        bottomNavigationBar: SafeArea(
          minimum: const EdgeInsets.fromLTRB(20, 8, 20, 10),
          child: DriverFormButton(
            label: l10n.savePickup,
            // The weight is required and must be more than 0.
            enabled:
                !_saving &&
                _photos.isNotEmpty &&
                (double.tryParse(_weightController.text.trim()) ?? 0) > 0,
            onPressed: widget.target != null
                ? () => _saveLive(widget.target!)
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          const DriverPickupSuccessScreen(isLastStop: true),
                    ),
                  ),
          ),
        ),
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
                  key: const Key('driver-mixed-form'),
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
                            title: l10n.mixedWasteForm,
                            gap: 16,
                            backAsset: '$driverPickupIconRoot/mixed_back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          DriverPickupStopSummary(
                            title:
                                widget.target?.sourceName ?? l10n.shreeSaiDairy,
                            subtitle: widget.target != null
                                ? l10n.stopPosition(
                                    widget.target!.stopOrder,
                                    widget.target!.totalStops,
                                  )
                                : l10n.mixedStopSevenOfSeven,
                            locationLabel: l10n.locationMatched,
                          ),
                          const SizedBox(height: 32),
                          DriverRequiredLabel(label: l10n.enterWeightKg),
                          const SizedBox(height: 8),
                          DriverEditableValueField(
                            controller: _weightController,
                            prefix: l10n.kgUnit,
                            placeholder: l10n.exampleWeight,
                            height: 55,
                          ),
                          const SizedBox(height: 24),
                          DriverRequiredLabel(
                            label: l10n.materialAndScalePhoto,
                          ),
                          const SizedBox(height: 8),
                          DriverCaptureArea(
                            captureKey: const Key('driver-capture-photo-mixed'),
                            label: l10n.capturePhoto,
                            icon: _photos.length < _maximumPhotos
                                ? '$driverPickupIconRoot/camera.svg'
                                : '$driverPickupIconRoot/mixed_camera.svg',
                            active: _photos.length < _maximumPhotos,
                            onTap: () => _capturePhoto(l10n.capturePhoto),
                          ),
                          if (_photos.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                for (
                                  var index = 0;
                                  index < _photos.length;
                                  index++
                                ) ...[
                                  Expanded(
                                    child: DriverPhotoThumbnail(
                                      key: ValueKey(_photos[index].path),
                                      filePath: _photos[index].path,
                                      removeIcon:
                                          '$driverPickupIconRoot/mixed_photo_remove.svg',
                                      width: double.infinity,
                                      height: 92,
                                      onPreview: () =>
                                          DriverPhotoPreviewDialog.show(
                                            context,
                                            _photos[index].path,
                                          ),
                                      onRemove: () => setState(
                                        () => _photos.removeAt(index),
                                      ),
                                    ),
                                  ),
                                  if (index < _photos.length - 1)
                                    const SizedBox(width: 8),
                                ],
                                if (_photos.length == 1)
                                  const Expanded(child: SizedBox()),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          Text(
                            l10n.supportedPhotoFormats,
                            style: DriverTextStyles.regular12.copyWith(
                              color: DriverColors.neutral600,
                            ),
                          ),
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
