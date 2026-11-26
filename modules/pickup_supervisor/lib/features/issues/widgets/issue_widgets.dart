import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/widgets/module_text_fields.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_button.dart';
import 'package:pickup_supervisor/features/issues/model/issue_models.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _attention = 'assets/icons/supervisor/attention';
const _flags = 'assets/icons/supervisor/flags';
const _shadow = [
  BoxShadow(color: DriverColors.shadow, blurRadius: 4, offset: Offset(0, 2)),
];

Widget _svg(String asset, double size) =>
    SvgPicture.asset(asset, package: _package, width: size, height: size);

extension IssueText on DriverLocalizations {
  String issueType(IssueType t) => switch (t) {
    IssueType.vehicleBreakdown => attentionVehicleBreakdown,
    IssueType.sourceProblem => isTypeSourceProblem,
  };

  String issueStatus(IssueStatus s) => switch (s) {
    IssueStatus.open => isOpen,
    IssueStatus.escalated => isEscalated,
    IssueStatus.resolved => isResolved,
  };
}

/// Open (red), Escalated (amber) or Resolved (green) pill.
class IssueStatusChip extends StatelessWidget {
  const IssueStatusChip({super.key, required this.status});

  final IssueStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      IssueStatus.open => (DriverColors.red50, DriverColors.red600),
      IssueStatus.escalated => (
        DriverColors.escalatedBg,
        DriverColors.escalatedText,
      ),
      IssueStatus.resolved => (
        DriverColors.primary100,
        DriverColors.resolvedText,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        DriverLocalizations.of(context).issueStatus(status),
        style: DriverTextStyles.semibold12.copyWith(color: fg, height: 1.37),
      ),
    );
  }
}

/// "Raised 10:42 AM"
class IssueRaisedText extends StatelessWidget {
  const IssueRaisedText({super.key, required this.time});

  final String time;

  @override
  Widget build(BuildContext context) => Text(
    DriverLocalizations.of(context).isRaised(time),
    style: DriverTextStyles.medium12.copyWith(
      color: DriverColors.neutral400,
      height: 1.37,
    ),
  );
}

/// Issue in the list. Open issues are highlighted (red icon, green arrow).
class IssueListCard extends StatelessWidget {
  const IssueListCard({super.key, required this.issue, required this.onTap});

  final SupervisorIssue issue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final open = issue.status == IssueStatus.open;
    return Material(
      color: DriverColors.neutral50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: DriverColors.cool400),
      ),
      child: InkWell(
        key: Key('issue-card-${issue.id}'),
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: open ? DriverColors.red50 : DriverColors.cool200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _svg(
                      open
                          ? '$_attention/issue_red.svg'
                          : '$_attention/issue_muted.svg',
                      24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.issueType(issue.type),
                            style: DriverTextStyles.semibold16.copyWith(
                              color: DriverColors.neutral900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.isDriverRole(issue.driverName),
                            style: DriverTextStyles.medium14.copyWith(
                              color: DriverColors.neutral600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              IssueStatusChip(status: issue.status),
                              IssueRaisedText(time: issue.raisedAt),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 15,
              right: 15,
              child: _svg(
                open ? '$_flags/arrow_green.svg' : '$_flags/arrow_muted.svg',
                12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// White card with the Figma "drop shadow 0 2 4 12%".
class IssueSurface extends StatelessWidget {
  const IssueSurface({super.key, required this.child, required this.padding});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: _shadow,
    ),
    child: child,
  );
}

/// Vehicle plate, raised time and status.
class IssueVehicleCard extends StatelessWidget {
  const IssueVehicleCard({super.key, required this.issue});

  final SupervisorIssue issue;

  @override
  Widget build(BuildContext context) => IssueSurface(
    padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
    child: Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: DriverColors.primary100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: _svg('$_attention/truck.svg', 24),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                issue.vehicle,
                style: DriverTextStyles.semibold16.copyWith(
                  color: DriverColors.neutral900,
                ),
              ),
              const SizedBox(height: 2),
              IssueRaisedText(time: issue.raisedAt),
            ],
          ),
        ),
        const SizedBox(width: 10),
        IssueStatusChip(status: issue.status),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, thickness: 1, color: DriverColors.cool400);
}

/// Driver, contact number and route, each a label over a bulleted value.
class IssueInfoCard extends StatelessWidget {
  const IssueInfoCard({super.key, required this.fields});

  final List<(String label, String value)> fields;

  @override
  Widget build(BuildContext context) => IssueSurface(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, f) in fields.indexed) ...[
          if (i > 0) ...[
            const SizedBox(height: 12),
            const _Divider(),
            const SizedBox(height: 12),
          ],
          Text(
            f.$1,
            style: DriverTextStyles.semibold14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '•  ${f.$2}',
              style: DriverTextStyles.semibold14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
          ),
        ],
      ],
    ),
  );
}

/// Bordered card with a title, a divider and "Label : value" lines (Reason
/// for Issue, Resolved, Escalated).
class IssueSectionCard extends StatelessWidget {
  const IssueSectionCard({
    super.key,
    required this.title,
    required this.borderColor,
    required this.lines,
  });

  final InlineSpan title;
  final Color borderColor;
  final List<(String label, String value)> lines;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          title,
          style: DriverTextStyles.semibold18.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        const SizedBox(height: 12),
        const _Divider(),
        const SizedBox(height: 12),
        for (final (i, l) in lines.indexed) ...[
          if (i > 0) const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(text: l.$1, style: DriverTextStyles.semibold14),
                TextSpan(text: ' ${l.$2}'),
              ],
            ),
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Body of the "Mark as resolved" sheet. Pops with the entered text.
class ResolveIssueSheet extends StatefulWidget {
  const ResolveIssueSheet({super.key});

  @override
  State<ResolveIssueSheet> createState() => _ResolveIssueSheetState();
}

class _ResolveIssueSheetState extends State<ResolveIssueSheet> {
  final _text = TextEditingController();

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final done = _text.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.isSheetTitle,
          style: DriverTextStyles.bold20.copyWith(
            color: DriverColors.neutral950,
            height: 1.37,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.isSheetBody,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral600,
            height: 1.37,
          ),
        ),
        const SizedBox(height: 24),
        ModuleFieldLabel(l10n.isWhatWasDoneLabel, required: true),
        const SizedBox(height: 8),
        Container(
          height: 133,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: DriverColors.neutral50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: DriverColors.cool400),
          ),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('issue-resolve-text'),
                  controller: _text,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  maxLength: 150,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: DriverTextStyles.regular14.copyWith(
                    color: DriverColors.neutral950,
                    height: 22 / 14,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    filled: false,
                    counterText: '',
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  l10n.skMaxChars,
                  style: DriverTextStyles.regular12.copyWith(
                    color: DriverColors.neutral400,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ModuleButton(
                key: const Key('issue-resolve-cancel'),
                label: l10n.apCancel,
                variant: ModuleButtonVariant.neutral,
                height: 52,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModuleButton(
                key: const Key('issue-resolve-confirm'),
                label: l10n.isMarkResolved,
                height: 52,
                radius: 14,
                onPressed: done.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(done),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Body of the "Escalate this issue?" popup. Pops with true on Escalate.
class EscalateIssuePopup extends StatelessWidget {
  const EscalateIssuePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.isEscalateTitle,
          textAlign: TextAlign.center,
          style: DriverTextStyles.bold24.copyWith(
            color: DriverColors.neutral950,
            height: 28 / 24,
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            l10n.isEscalateBody,
            textAlign: TextAlign.center,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: ModuleButton(
                key: const Key('issue-escalate-cancel'),
                label: l10n.apCancel,
                variant: ModuleButtonVariant.neutral,
                height: 52,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ModuleButton(
                key: const Key('issue-escalate-confirm'),
                label: l10n.isEscalate,
                height: 52,
                radius: 14,
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
