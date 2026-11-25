import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/core/widgets/module_toast.dart';
import 'package:pickup_supervisor/features/issues/model/issue_mock_data.dart';
import 'package:pickup_supervisor/features/issues/model/issue_models.dart';
import 'package:pickup_supervisor/features/issues/widgets/issue_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M03 Issue overview in its Open, Escalated or Resolved state.
///
/// Open: Escalate (confirmation popup) and Mark resolved (sheet).
/// Escalated: Mark resolved. Resolved: no actions. Each action shows a toast
/// once and reports the updated issue through [onChanged].
class PickupSupervisorIssueDetailScreen extends StatelessWidget {
  const PickupSupervisorIssueDetailScreen({
    super.key,
    required this.issue,
    this.onChanged,
  });

  final SupervisorIssue issue;
  final ValueChanged<SupervisorIssue>? onChanged;

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: _IssueDetailView(issue: issue, onChanged: onChanged),
  );
}

class _IssueDetailView extends StatefulWidget {
  const _IssueDetailView({required this.issue, required this.onChanged});

  final SupervisorIssue issue;
  final ValueChanged<SupervisorIssue>? onChanged;

  @override
  State<_IssueDetailView> createState() => _IssueDetailViewState();
}

class _IssueDetailViewState extends State<_IssueDetailView> {
  late SupervisorIssue _issue = widget.issue;

  @override
  void didUpdateWidget(covariant _IssueDetailView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.issue != widget.issue) _issue = widget.issue;
  }

  void _update(SupervisorIssue updated) {
    setState(() => _issue = updated);
    widget.onChanged?.call(updated);
  }

  Future<void> _resolve() async {
    final done = await showModuleSheet<String>(
      context,
      showHandle: false,
      builder: (_) => const DriverLocalizationScope(child: ResolveIssueSheet()),
    );
    if (done == null || !mounted) return;
    _update(
      _issue.copyWith(
        status: IssueStatus.resolved,
        actedBy: IssueMockData.supervisorName,
        actedAt: IssueMockData.actionTime,
        resolution: done,
      ),
    );
    final l10n = DriverLocalizations.of(context);
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.isResolvedToastTitle,
      message: l10n.isResolvedToastBody(_issue.driverName),
    );
  }

  Future<void> _escalate() async {
    final ok = await showModulePopup<bool>(
      context,
      builder: (_) =>
          const DriverLocalizationScope(child: EscalateIssuePopup()),
    );
    if (ok != true || !mounted) return;
    _update(
      _issue.copyWith(
        status: IssueStatus.escalated,
        actedBy: IssueMockData.supervisorName,
        actedAt: IssueMockData.actionTime,
      ),
    );
    final l10n = DriverLocalizations.of(context);
    ModuleToast.show(
      context,
      kind: ModuleToastKind.success,
      title: l10n.isEscalatedToastTitle,
      message: l10n.isEscalatedToastBody,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final issue = _issue;
    final by = l10n.isByValue(issue.actedBy, issue.actedAt);
    return ModulePage(
      key: const Key('supervisor-issue-detail-screen'),
      bottom: switch (issue.status) {
        IssueStatus.open => Row(
          children: [
            Expanded(
              child: ModuleButton(
                key: const Key('issue-escalate'),
                label: l10n.isEscalate,
                variant: ModuleButtonVariant.outline,
                height: 52,
                onPressed: _escalate,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModuleButton(
                key: const Key('issue-mark-resolved'),
                label: l10n.isMarkResolved,
                height: 52,
                onPressed: _resolve,
              ),
            ),
          ],
        ),
        IssueStatus.escalated => ModuleButton(
          key: const Key('issue-mark-resolved'),
          label: l10n.isMarkResolved,
          height: 52,
          onPressed: _resolve,
        ),
        IssueStatus.resolved => null,
      },
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const ModuleBackButton(),
          const SizedBox(height: 24),
          IssueVehicleCard(issue: issue),
          const SizedBox(height: 16),
          IssueInfoCard(
            fields: [
              (l10n.attentionDriver, issue.driverName),
              (l10n.attentionContactNumber, issue.phone),
              (l10n.attentionRoute, issue.route),
            ],
          ),
          const SizedBox(height: 20),
          IssueSectionCard(
            borderColor: DriverColors.red600,
            title: TextSpan(
              children: [
                TextSpan(text: l10n.attentionReasonFor),
                TextSpan(
                  text: l10n.attentionIssueWord,
                  style: const TextStyle(color: DriverColors.red500),
                ),
              ],
            ),
            lines: [
              (l10n.isTypeLabel, l10n.issueType(issue.type)),
              (l10n.isDriverNote, issue.driverNote),
            ],
          ),
          if (issue.status == IssueStatus.resolved) ...[
            const SizedBox(height: 20),
            IssueSectionCard(
              key: const Key('issue-resolved-card'),
              borderColor: DriverColors.primary500,
              title: TextSpan(
                text: l10n.isResolved,
                style: const TextStyle(color: DriverColors.resolvedText),
              ),
              lines: [(l10n.isBy, by), (l10n.isWhatWasDone, issue.resolution)],
            ),
          ],
          if (issue.status == IssueStatus.escalated) ...[
            const SizedBox(height: 20),
            IssueSectionCard(
              key: const Key('issue-escalated-card'),
              borderColor: DriverColors.escalatedBorder,
              title: TextSpan(
                text: l10n.isEscalated,
                style: const TextStyle(color: DriverColors.escalatedText),
              ),
              lines: [
                (l10n.isBy, by),
                (l10n.isTold, l10n.isToldValue(issue.iecName)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
