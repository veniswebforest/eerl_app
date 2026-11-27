import 'package:flutter/material.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/features/issues/data/issue_live_data.dart';
import 'package:pickup_supervisor/features/issues/model/issue_models.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_page.dart';
import 'package:pickup_supervisor/features/issues/model/issue_mock_data.dart';
import 'package:pickup_supervisor/features/issues/view/issue_detail_screen.dart';
import 'package:pickup_supervisor/features/issues/widgets/issue_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

/// PS-M03 Issues. Opens from the home Issues tile and the drawer's Issues.
/// Escalating or resolving on the detail screen updates the list.
class PickupSupervisorIssuesScreen extends StatelessWidget {
  const PickupSupervisorIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) => DriverLocalizationScope(
    child: OutboundLiveBuilder<List<SupervisorIssue>>(
      load: loadLiveIssues,
      fallback: const _IssuesView(),
      builder: (context, issues, _) =>
          _IssuesView(key: ValueKey(issues), issues: issues),
    ),
  );
}

class _IssuesView extends StatefulWidget {
  const _IssuesView({super.key, this.issues});

  /// Live issues; null shows the design samples.
  final List<SupervisorIssue>? issues;

  @override
  State<_IssuesView> createState() => _IssuesViewState();
}

class _IssuesViewState extends State<_IssuesView> {
  late final _issues = [...(widget.issues ?? IssueMockData.issues)];

  void _open(int index) => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => PickupSupervisorIssueDetailScreen(
        issue: _issues[index],
        onChanged: (updated) => setState(() => _issues[index] = updated),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return ModulePage(
      key: const Key('supervisor-issues-screen'),
      child: ListView(
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        children: [
          Row(
            children: [
              const ModuleBackButton(),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.attentionIssues,
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (final (i, issue) in _issues.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            IssueListCard(issue: issue, onTap: () => _open(i)),
          ],
        ],
      ),
    );
  }
}
