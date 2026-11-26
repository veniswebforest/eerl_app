import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/forms/module_input_rules.dart';
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
    // Keep the "98250 12458" grouping; drop the +91 shown in its own box.
    text: widget.person?.phone?.replaceFirst(RegExp(r'^\+91\s*'), '') ?? '',
  );
  late final _aadhaar = TextEditingController(
    text: widget.person?.idNumber ?? '',
  );
  final _removedPhotos = <String>{};

  /// Errors show after the first Save, then update as the user types.
  var _submitted = false;

  bool get _isEdit => widget.person != null;
  bool get _isDriver => widget.kind == DriverLabourKind.driver;

  @override
  void initState() {
    super.initState();
    for (final c in [_name, _mobile, _aadhaar]) {
      c.addListener(_revalidate);
    }
  }

  void _revalidate() {
    if (_submitted) setState(() {});
  }

  String? _nameError(DriverLocalizations l10n) =>
      ModuleValidators.fullName(l10n, _name.text);

  /// Drivers sign in with their phone, so it is required for them only.
  String? _mobileError(DriverLocalizations l10n) =>
      ModuleValidators.phone(l10n, _mobile.text, required: _isDriver);

  String? _idError(DriverLocalizations l10n) =>
      ModuleValidators.idNumber(l10n, _aadhaar.text);

  void _save(DriverLocalizations l10n) {
    FocusScope.of(context).unfocus();
    setState(() => _submitted = true);
    final valid =
        _nameError(l10n) == null &&
        _mobileError(l10n) == null &&
        _idError(l10n) == null;
    if (valid) Navigator.of(context).maybePop();
  }

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
    // Edit starts with both photos on file; Add starts with none.
    bool has(String photo) => _isEdit && !_removedPhotos.contains(photo);
    Widget photoSection(String label, String photo, String keyName) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        const SizedBox(height: 8),
        DriverCaptureArea(
          captureKey: Key('driver-labour-capture-$keyName'),
          label: l10n.dlCapturePhoto,
          icon: has(photo)
              ? DriverLabourAssets.cameraAddDisabled
              : DriverLabourAssets.cameraAdd,
          active: !has(photo),
        ),
        if (has(photo)) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: 139,
            child: DriverLabourPhotoTile(
              asset: photo,
              onRemove: () => setState(() => _removedPhotos.add(photo)),
            ),
          ),
        ],
      ],
    );

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
              label: l10n.dlSave,
              onPressed: () => _save(l10n),
            ),
          ),
        ],
      ),
      child: ListView(
        clipBehavior: Clip.none,
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
            kind: ModuleInputKind.name,
            fieldKey: const Key('driver-labour-name'),
            errorText: _submitted ? _nameError(l10n) : null,
          ),
          const SizedBox(height: 16),
          DriverLabourMobileField(
            label: l10n.dlMobileNumber,
            countryCode: l10n.dlCountryCode,
            hint: l10n.dlEnterMobileNumber,
            controller: _mobile,
            required: _isDriver,
            fieldKey: const Key('driver-labour-mobile'),
            errorText: _submitted ? _mobileError(l10n) : null,
          ),
          const SizedBox(height: 16),
          DriverLabourTextField(
            label: l10n.dlIdNumberLabel,
            hint: l10n.dlIdNumberHint,
            controller: _aadhaar,
            kind: ModuleInputKind.idNumber,
            // Last typed field: Done closes the keyboard.
            textInputAction: TextInputAction.done,
            fieldKey: const Key('driver-labour-id'),
            errorText: _submitted ? _idError(l10n) : null,
          ),
          const SizedBox(height: 16),
          photoSection(
            l10n.dlProfilePhotoLabel,
            DriverLabourAssets.profilePhoto,
            'profile',
          ),
          const SizedBox(height: 16),
          photoSection(
            l10n.dlIdProofPhoto,
            DriverLabourAssets.idCard,
            'id-proof',
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dlBothOptional,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
        ],
      ),
    );
  }
}
