import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetRoot = 'assets/icons/supervisor/attention';
const _assetPackage = 'pickup_supervisor';
const _shadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
];

class SupervisorApprovalRequestsScreen extends StatefulWidget {
  const SupervisorApprovalRequestsScreen({super.key});

  @override
  State<SupervisorApprovalRequestsScreen> createState() =>
      _SupervisorApprovalRequestsScreenState();
}

class _SupervisorApprovalRequestsScreenState
    extends State<SupervisorApprovalRequestsScreen> {
  var _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final requests = [
            _ApprovalRequest(
              title: l10n.attentionCorrectionFromDriver,
              source: l10n.attentionHotelRajdhaniStop,
              detail: l10n.attentionDriverCorrectionDetail,
              sent: l10n.attentionSentToday,
            ),
            _ApprovalRequest(
              title: l10n.attentionExtraPickup,
              source: l10n.attentionAbcPlastic,
              detail: l10n.attentionExtraPickupDetail,
              sent: l10n.attentionSent21Oct,
            ),
            _ApprovalRequest(
              title: l10n.attentionCorrectionFromPickupPoint,
              source: l10n.attentionGreenParkSociety,
              detail: l10n.attentionPickupPointCorrectionDetail,
              sent: l10n.attentionSent20Oct,
            ),
          ];
          return _AttentionScaffold(
            screenKey: const Key('supervisor-approval-requests-screen'),
            header: _AttentionHeader(
              title: l10n.attentionApprovalRequests,
              subtitle: l10n.attentionApprovalSubtitle,
            ),
            child: Column(
              children: [
                _ChoiceBar(
                  choices: [
                    l10n.attentionToApproveCount,
                    l10n.attentionDoneCount,
                  ],
                  selected: _selectedTab,
                  onSelected: (value) => setState(() => _selectedTab = value),
                ),
                const SizedBox(height: 16),
                ...requests.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _ApprovalCard(
                      request: request,
                      l10n: l10n,
                      onApprove: () => _showApprovedDialog(context, l10n),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showApprovedDialog(
    BuildContext context,
    DriverLocalizations l10n,
  ) {
    return showDialog<void>(
      context: context,
      barrierColor: const Color(0x99000000),
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SizedBox(
          height: 402,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  l10n.attentionCorrectionApproved,
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.bold24.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.attentionCorrectionApprovedMessage,
                  textAlign: TextAlign.center,
                  style: DriverTextStyles.regular14.copyWith(
                    color: DriverColors.neutral600,
                    height: 19 / 14,
                  ),
                ),
                const SizedBox(height: 24),
                _WideButton(
                  label: l10n.attentionBackToApprovals,
                  onPressed: () => Navigator.pop(dialogContext),
                ),
                const SizedBox(height: 12),
                _WideButton(
                  label: l10n.attentionBackToHome,
                  background: DriverColors.cool200,
                  foreground: DriverColors.neutral950,
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.maybePop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SupervisorMyRequestsScreen extends StatefulWidget {
  const SupervisorMyRequestsScreen({super.key});

  @override
  State<SupervisorMyRequestsScreen> createState() =>
      _SupervisorMyRequestsScreenState();
}

class _SupervisorMyRequestsScreenState
    extends State<SupervisorMyRequestsScreen> {
  var _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final requests = [
            _MyRequest(
              title: l10n.attentionVehicleAdajan,
              status: _RequestStatus.waiting,
              description: l10n.attentionVehicleRequestDescription,
              response: l10n.attentionVehicleRequestResponse,
              sent: l10n.attentionSentTodayShort,
            ),
            _MyRequest(
              title: l10n.attentionLabourPalGam,
              status: _RequestStatus.approved,
              description: l10n.attentionLabourRequestDescription,
              response: l10n.attentionLabourRequestResponse,
              sent: l10n.attentionSent19Oct,
            ),
            _MyRequest(
              title: l10n.attentionPauseHotelShivam,
              status: _RequestStatus.approved,
              description: l10n.attentionPauseRequestDescription,
              response: l10n.attentionPauseRequestResponse,
              sent: l10n.attentionSent18Oct,
            ),
            _MyRequest(
              title: l10n.attentionStartSunriseSchool,
              status: _RequestStatus.declined,
              description: l10n.attentionStartRequestDescription,
              response: l10n.attentionStartRequestResponse,
              sent: l10n.attentionSent16Oct,
            ),
          ];
          final visible = _selectedFilter == 0
              ? requests
              : requests
                    .where((item) => item.status.index == _selectedFilter - 1)
                    .toList();
          return _AttentionScaffold(
            screenKey: const Key('supervisor-my-requests-screen'),
            header: _AttentionHeader(
              title: l10n.attentionMyRequests,
              subtitle: l10n.attentionToCollectionHead,
            ),
            child: Column(
              children: [
                _ChoiceBar(
                  choices: [
                    l10n.attentionAll4,
                    l10n.attentionWaiting1,
                    l10n.attentionApproved2,
                    l10n.attentionDeclined1,
                  ],
                  selected: _selectedFilter,
                  onSelected: (value) =>
                      setState(() => _selectedFilter = value),
                  compact: true,
                ),
                const SizedBox(height: 16),
                ...visible.map(
                  (request) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _MyRequestCard(request: request, l10n: l10n),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SupervisorSuggestionsScreen extends StatelessWidget {
  const SupervisorSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final suggestions = [
            _Suggestion(
              title: l10n.attentionMoveHotelRajdhani,
              description: l10n.attentionMoveHotelDescription,
              secondary: l10n.attentionMoveHotelRoute,
              saving: l10n.attentionSaving31Km,
            ),
            _Suggestion(
              title: l10n.attentionReorderAdajan,
              description: l10n.attentionReorderDescription,
              secondary: l10n.attentionReorderSecondary,
              saving: l10n.attentionSaving12Min,
            ),
            _Suggestion(
              title: l10n.attentionCombineFridayRoutes,
              description: l10n.attentionCombineDescription,
              secondary: l10n.attentionCombineSecondary,
              saving: l10n.attentionSavingOneVehicle,
            ),
          ];
          return _AttentionScaffold(
            screenKey: const Key('supervisor-suggestions-screen'),
            header: _AttentionHeader(
              title: l10n.attentionSuggestions,
              subtitle: l10n.attentionSuggestionsSubtitle,
            ),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _FilterChip(label: l10n.attentionAll3, selected: true),
                ),
                const SizedBox(height: 16),
                ...suggestions.map(
                  (suggestion) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _SuggestionCard(suggestion: suggestion, l10n: l10n),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class SupervisorIssuesScreen extends StatelessWidget {
  const SupervisorIssuesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          final issues = [
            _Issue(l10n.attentionVehicleBreakdown, l10n.attentionRameshDriver),
            _Issue(l10n.attentionSourceClosed, l10n.attentionMohanDriver),
            _Issue(l10n.attentionVehicleBreakdown, l10n.attentionPrakashDriver),
          ];
          return _AttentionScaffold(
            screenKey: const Key('supervisor-issues-screen'),
            header: _AttentionHeader(title: l10n.attentionIssues),
            child: Column(
              children: List.generate(
                issues.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _IssueTile(
                    issue: issues[index],
                    highlighted: index == 0,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SupervisorIssueDetailScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SupervisorIssueDetailScreen extends StatelessWidget {
  const SupervisorIssueDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return _AttentionScaffold(
            screenKey: const Key('supervisor-issue-detail-screen'),
            header: const _AttentionHeader(showTitle: false),
            child: Column(
              children: [
                _Surface(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF8E3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(7),
                        child: SvgPicture.asset(
                          '$_assetRoot/truck.svg',
                          package: _assetPackage,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.attentionVehicleNumber,
                        style: DriverTextStyles.semibold16.copyWith(
                          color: DriverColors.neutral900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Surface(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _DetailField(
                        label: l10n.attentionDriver,
                        value: l10n.attentionRameshAhir,
                      ),
                      _DetailField(
                        label: l10n.attentionContactNumber,
                        value: l10n.attentionPhoneNumber,
                      ),
                      _DetailField(
                        label: l10n.attentionRoute,
                        value: l10n.attentionAdajanMorning,
                        last: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(15, 14, 15, 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: DriverColors.red500),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(text: l10n.attentionReasonFor),
                            TextSpan(
                              text: l10n.attentionIssueWord,
                              style: const TextStyle(
                                color: DriverColors.red500,
                              ),
                            ),
                          ],
                        ),
                        style: DriverTextStyles.semibold18.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                      const Divider(height: 22, color: DriverColors.cool400),
                      Text(
                        l10n.attentionIssueReason,
                        style: DriverTextStyles.medium14.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.attentionIssueRemarks,
                        style: DriverTextStyles.medium14.copyWith(
                          color: DriverColors.neutral950,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _AttentionScaffold extends StatelessWidget {
  const _AttentionScaffold({
    required this.screenKey,
    required this.header,
    required this.child,
  });

  final Key screenKey;
  final Widget header;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: screenKey,
      backgroundColor: DriverColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [header, const SizedBox(height: 18), child],
          ),
        ),
      ),
    );
  }
}

class _AttentionHeader extends StatelessWidget {
  const _AttentionHeader({this.title, this.subtitle, this.showTitle = true});

  final String? title;
  final String? subtitle;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Material(
          color: DriverColors.primary500,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: const Key('supervisor-attention-back'),
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SvgPicture.asset(
                  '$_assetRoot/back.svg',
                  package: _assetPackage,
                ),
              ),
            ),
          ),
        ),
        if (showTitle) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? '',
                  style: DriverTextStyles.semibold20.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 1),
                  Text(
                    subtitle!,
                    style: DriverTextStyles.regular12.copyWith(
                      color: DriverColors.neutral600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ChoiceBar extends StatelessWidget {
  const _ChoiceBar({
    required this.choices,
    required this.selected,
    required this.onSelected,
    this.compact = false,
  });

  final List<String> choices;
  final int selected;
  final ValueChanged<int> onSelected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: choices.length,
        separatorBuilder: (_, _) => SizedBox(width: compact ? 7 : 8),
        itemBuilder: (_, index) => _FilterChip(
          label: choices[index],
          selected: selected == index,
          onTap: () => onSelected(index),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? DriverColors.primary500 : Colors.white,
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? DriverColors.primary500 : DriverColors.border,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
          child: Text(
            label,
            style: DriverTextStyles.medium12.copyWith(
              color: selected ? Colors.white : DriverColors.neutral900,
            ),
          ),
        ),
      ),
    );
  }
}

class _Surface extends StatelessWidget {
  const _Surface({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: child,
    );
  }
}

class _ApprovalRequest {
  const _ApprovalRequest({
    required this.title,
    required this.source,
    required this.detail,
    required this.sent,
  });

  final String title;
  final String source;
  final String detail;
  final String sent;
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.request,
    required this.l10n,
    required this.onApprove,
  });

  final _ApprovalRequest request;
  final DriverLocalizations l10n;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context) {
    return _Surface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              _StatusChip(
                label: l10n.attentionWaiting,
                asset: '$_assetRoot/waiting.svg',
                foreground: const Color(0xFFB26A00),
                background: const Color(0xFFFFF4E0),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(request.source, style: DriverTextStyles.medium14),
          const SizedBox(height: 5),
          Text(
            request.detail,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            request.sent,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _WideButton(
                  label: l10n.attentionDecline,
                  outlined: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WideButton(
                  label: l10n.attentionApprove,
                  onPressed: onApprove,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _RequestStatus { waiting, approved, declined }

class _MyRequest {
  const _MyRequest({
    required this.title,
    required this.status,
    required this.description,
    required this.response,
    required this.sent,
  });

  final String title;
  final _RequestStatus status;
  final String description;
  final String response;
  final String sent;
}

class _MyRequestCard extends StatelessWidget {
  const _MyRequestCard({required this.request, required this.l10n});

  final _MyRequest request;
  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final config = switch (request.status) {
      _RequestStatus.waiting => (
        l10n.attentionWaiting,
        '$_assetRoot/waiting.svg',
        const Color(0xFFB26A00),
        const Color(0xFFFFF4E0),
      ),
      _RequestStatus.approved => (
        l10n.attentionApproved,
        '$_assetRoot/approved.svg',
        DriverColors.primary500,
        DriverColors.primary50,
      ),
      _RequestStatus.declined => (
        l10n.attentionDeclined,
        '$_assetRoot/declined.svg',
        DriverColors.red500,
        DriverColors.red100,
      ),
    };
    return _Surface(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  request.title,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: config.$1,
                asset: config.$2,
                foreground: config.$3,
                background: config.$4,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.description,
            style: DriverTextStyles.regular14.copyWith(
              color: DriverColors.neutral900,
              height: 19 / 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            request.response,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            request.sent,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.asset,
    required this.foreground,
    required this.background,
  });

  final String label;
  final String asset;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            asset,
            package: _assetPackage,
            width: 13,
            height: 13,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: DriverTextStyles.medium12.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

class _Suggestion {
  const _Suggestion({
    required this.title,
    required this.description,
    required this.secondary,
    required this.saving,
  });

  final String title;
  final String description;
  final String secondary;
  final String saving;
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion, required this.l10n});

  final _Suggestion suggestion;
  final DriverLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: DriverColors.border),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            suggestion.title,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            suggestion.description,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            suggestion.secondary,
            style: DriverTextStyles.regular12.copyWith(
              color: DriverColors.neutral500,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 7,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: DriverColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      '$_assetRoot/saving.svg',
                      package: _assetPackage,
                      width: 13,
                      height: 13,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        suggestion.saving,
                        style: DriverTextStyles.medium12.copyWith(
                          color: DriverColors.primary500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.attentionLast30Days,
                style: DriverTextStyles.regular12.copyWith(
                  color: DriverColors.neutral600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _WideButton(
                  label: l10n.attentionDismiss,
                  outlined: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _WideButton(
                  label: l10n.attentionApply,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Issue {
  const _Issue(this.title, this.driver);

  final String title;
  final String driver;
}

class _IssueTile extends StatelessWidget {
  const _IssueTile({
    required this.issue,
    required this.highlighted,
    required this.onTap,
  });

  final _Issue issue;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? DriverColors.primary500 : DriverColors.cool400;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 76),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: highlighted
                      ? const Color(0xFFFFEEEE)
                      : DriverColors.cool200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  highlighted
                      ? '$_assetRoot/issue_red.svg'
                      : '$_assetRoot/issue_muted.svg',
                  package: _assetPackage,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: DriverTextStyles.semibold16.copyWith(
                        color: DriverColors.neutral700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      issue.driver,
                      style: DriverTextStyles.medium14.copyWith(
                        color: DriverColors.neutral600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.north_east, color: color, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailField extends StatelessWidget {
  const _DetailField({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral600,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '  •  $value',
          style: DriverTextStyles.medium14.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
        if (!last) const Divider(height: 14, color: DriverColors.cool400),
      ],
    );
  }
}

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.background = DriverColors.primary500,
    this.foreground = Colors.white,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    );
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(44),
          foregroundColor: DriverColors.primary500,
          side: const BorderSide(color: DriverColors.primary500),
          shape: shape,
        ),
        child: Text(label, style: DriverTextStyles.semibold16),
      );
    }
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(44),
        backgroundColor: background,
        foregroundColor: foreground,
        shape: shape,
      ),
      child: Text(label, style: DriverTextStyles.semibold16),
    );
  }
}
