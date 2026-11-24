import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_pickup_form_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_common_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_form_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Add New Driver / Add New Labour, and Edit when [person] is given.
class DriverLabourFormScreen extends StatelessWidget {
  const DriverLabourFormScreen({super.key, required this.kind, this.person});

  final DriverLabourKind kind;
  final DriverLabourPerson? person;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _FormView(kind: kind, person: person),
  );
}

class _FormView extends StatefulWidget {
  const _FormView({required this.kind, required this.person});

  final DriverLabourKind kind;
  final DriverLabourPerson? person;

  @override
  State<_FormView> createState() => _FormViewState();
}

class _FormViewState extends State<_FormView> {
  late final _name = TextEditingController(text: widget.person?.name ?? '');
  late final _mobile = TextEditingController(
    text:
        widget.person?.phone
            ?.replaceAll(RegExp(r'\D'), '')
            .replaceFirst(RegExp(r'^91'), '') ??
        '',
  );
  late final _aadhaar = TextEditingController(
    text: widget.person?.idNumber ?? '',
  );
  final _removedPhotos = <String>{};

  bool get _isEdit => widget.person != null;
  bool get _isDriver => widget.kind == DriverLabourKind.driver;

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _aadhaar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final title = _isEdit
        ? (_isDriver ? l10n.dlEditDriver : l10n.dlEditLabour)
        : (_isDriver ? l10n.dlAddNewDriver : l10n.dlAddNewLabour);
    final photos = [
      DriverLabourAssets.profilePhoto,
      DriverLabourAssets.idCard,
    ].where((p) => !_removedPhotos.contains(p)).toList();

    return ModulePage(
      bottom: Row(
        children: [
          Expanded(
            child: DriverLabourSecondaryButton(
              key: const Key('driver-labour-form-cancel'),
              label: l10n.dlCancel,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DriverPrimaryButton(
              key: const Key('driver-labour-form-save'),
              radius: 12,
              label: l10n.dlSaveSelect,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
        ],
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const ModuleBackButton(),
          const SizedBox(height: 24),
          Text(
            title,
            style: DriverTextStyles.semibold20.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 24),
          DriverLabourTextField(
            label: l10n.dlFullName,
            hint: l10n.dlEnterFullName,
            controller: _name,
            required: true,
          ),
          const SizedBox(height: 16),
          DriverLabourMobileField(
            label: l10n.dlMobileNumber,
            countryCode: l10n.dlCountryCode,
            hint: l10n.dlEnterMobileNumber,
            controller: _mobile,
            required: _isDriver,
          ),
          const SizedBox(height: 16),
          DriverLabourTextField(
            label: l10n.dlAadhaarLabel,
            hint: l10n.dlAadhaarHint,
            controller: _aadhaar,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.dlProfilePhoto,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          DriverCaptureArea(
            captureKey: const Key('driver-labour-capture'),
            label: l10n.dlCapturePhoto,
            icon: _isEdit
                ? DriverLabourAssets.cameraAddDisabled
                : DriverLabourAssets.cameraAdd,
            active: !_isEdit,
          ),
          if (_isEdit && photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < photos.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: DriverLabourPhotoTile(
                      asset: photos[i],
                      onRemove: () =>
                          setState(() => _removedPhotos.add(photos[i])),
                    ),
                  ),
                ],
                if (photos.length == 1) const Spacer(),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Text(
            l10n.dlUploadHint,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
