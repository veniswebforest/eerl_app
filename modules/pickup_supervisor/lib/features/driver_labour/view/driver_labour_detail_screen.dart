import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/widgets/module_toast.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/model/driver_labour_person.dart';
import 'package:pickup_supervisor/features/driver_labour/view/driver_labour_form_screen.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_assets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_common_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_detail_widgets.dart';
import 'package:pickup_supervisor/features/driver_labour/widgets/driver_labour_feedback.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// Driver / labour information, in its active or deactivated state.
class DriverLabourDetailScreen extends StatelessWidget {
  const DriverLabourDetailScreen({super.key, required this.person});

  final DriverLabourPerson person;

  @override
  Widget build(BuildContext context) =>
      DriverLocalizationScope(child: _DetailView(person: person));
}

class _DetailView extends StatefulWidget {
  const _DetailView({required this.person});

  final DriverLabourPerson person;

  @override
  State<_DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<_DetailView> {
  late bool _active = widget.person.active;

  bool get _isDriver => widget.person.kind == DriverLabourKind.driver;

  Future<void> _deactivate(DriverLocalizations l10n) async {
    final confirmed = await showDriverLabourConfirmDialog(
      context,
      title: l10n.dlAreYouSure,
      message: _isDriver
          ? l10n.dlDeactivateDriverMessage
          : l10n.dlDeactivateLabourMessage,
      cancelLabel: l10n.dlCancel,
      confirmLabel: l10n.dlYes,
      confirmColor: DriverColors.red500,
    );
    if (!mounted || !confirmed) return;
    setState(() => _active = false);
    ModuleToast.show(
      context,
      kind: ModuleToastKind.error,
      title: l10n.dlDeactivatedTitle,
      message: l10n.dlDeactivatedBody,
    );
  }

  Future<void> _reactivate(DriverLocalizations l10n) async {
    final confirmed = await showDriverLabourConfirmDialog(
      context,
      title: l10n.dlAreYouSure,
      message: _isDriver
          ? l10n.dlReactiveDriverMessage
          : l10n.dlReactiveLabourMessage,
      cancelLabel: l10n.dlCancel,
      confirmLabel: l10n.dlYes,
      confirmColor: DriverColors.primary500,
      confirmRadius: 12,
    );
    if (!mounted || !confirmed) return;
    setState(() => _active = true);
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.dlReactivedTitle,
      message: l10n.dlReactivedBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final person = widget.person;
    final muted = !_active;
    final phone = person.phone ?? l10n.dlNoPhone;

    return ModulePage(
      bottom: _active
          ? Row(
              children: [
                Expanded(
                  child: DriverLabourDangerOutlineButton(
                    key: const Key('driver-labour-deactivate'),
                    label: l10n.dlDeactivate,
                    iconAsset: DriverLabourAssets.deactivate,
                    onPressed: () => _deactivate(l10n),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DriverPrimaryButton(
                    key: const Key('driver-labour-edit'),
                    radius: 12,
                    label: l10n.dlEdit,
                    icon: SvgPicture.asset(
                      DriverLabourAssets.edit,
                      package: DriverLabourAssets.package,
                      width: 20,
                      height: 20,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => DriverLabourFormScreen(
                          kind: person.kind,
                          person: person,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          : DriverPrimaryButton(
              key: const Key('driver-labour-reactive'),
              radius: 12,
              label: l10n.dlReactive,
              icon: SvgPicture.asset(
                DriverLabourAssets.reactivate,
                package: DriverLabourAssets.package,
                width: 20,
                height: 20,
              ),
              onPressed: () => _reactivate(l10n),
            ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const ModuleBackButton(),
          const SizedBox(height: 24),
          DriverLabourChipCard(
            iconAsset: DriverLabourAssets.user,
            text: person.code,
            muted: muted,
          ),
          if (person.warehouse != null) ...[
            const SizedBox(height: 12),
            DriverLabourChipCard(
              iconAsset: DriverLabourAssets.warehouse,
              text: person.warehouse!,
              muted: muted,
            ),
          ],
          const SizedBox(height: 16),
          DriverLabourInfoCard(
            muted: muted,
            rows: [
              DriverLabourInfoRowData(l10n.dlFullName, person.name),
              DriverLabourInfoRowData(l10n.dlMobileNumber, phone),
              DriverLabourInfoRowData(l10n.dlIdCardNumber, person.idNumber),
              DriverLabourInfoRowData(l10n.dlDateTime, person.dateTime),
            ],
          ),
          const SizedBox(height: 16),
          DriverLabourProofCard(title: l10n.dlProfilePhoto, muted: muted),
        ],
      ),
    );
  }
}
