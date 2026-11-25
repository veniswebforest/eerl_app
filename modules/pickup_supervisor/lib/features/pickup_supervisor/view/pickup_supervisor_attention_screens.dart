import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_count_chip.dart';
import 'package:pickup_supervisor/core/widgets/module_modal.dart';
import 'package:pickup_supervisor/features/pickup_supervisor/widgets/pickup_supervisor_approval_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _assetRoot = 'assets/icons/supervisor/attention';
const _assetPackage = 'pickup_supervisor';
const _shadow = <BoxShadow>[
  BoxShadow(color: Color(0x1F000000), blurRadius: 5, offset: Offset(0, 2)),
];

/// Approval requests opened from "Needs your attention" → Approvals.
///
/// "To approve" lists pending requests with Decline (reply sheet) and Approve
/// (success popup); "Done" lists approved and declined requests.
class PickupSupervisorApprovalRequestsScreen extends StatefulWidget {
  const PickupSupervisorApprovalRequestsScreen({
    super.key,
    this.initialShowDone = false,
  });

  final bool initialShowDone;

  @override
  State<PickupSupervisorApprovalRequestsScreen> createState() =>
      _PickupSupervisorApprovalRequestsScreenState();
}

enum _ApprovalKind { correction, extraPickup }

class _PickupSupervisorApprovalRequestsScreenState
    extends State<PickupSupervisorApprovalRequestsScreen> {
  static const _pendingCount = 2;
  static const _doneCount = 12;

  late bool _showDone = widget.initialShowDone;

  @override
  Widget build(BuildContext context) {
    return DriverLocalizationScope(
      child: Builder(
        builder: (context) {
          final l10n = DriverLocalizations.of(context);
          return _AttentionScaffold(
            screenKey: const Key('supervisor-approval-requests-screen'),
            header: _AttentionHeader(
              title: l10n.attentionApprovalRequests,
              subtitle: l10n.attentionApprovalSubtitle,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ModuleCountChip(
                      key: const Key('approval-tab-pending'),
                      label: l10n.apToApprove,
                      count: '$_pendingCount',
                      selected: !_showDone,
                      onTap: () => setState(() => _showDone = false),
                    ),
                    ModuleCountChip(
                      key: const Key('approval-tab-done'),
                      label: l10n.apDone,
                      count: '$_doneCount',
                      selected: _showDone,
                      onTap: () => setState(() => _showDone = true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(_showDone ? _doneCards(l10n) : _pendingCards(context, l10n))
                    .expand((card) => [card, const SizedBox(height: 16)]),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _pendingCards(BuildContext context, DriverLocalizations l10n) {
    return [
      ApprovalRequestCard(
        key: const Key('approval-request-correction'),
        title: l10n.attentionCorrectionFromDriver,
        source: l10n.attentionHotelRajdhaniStop,
        detail: l10n.attentionDriverCorrectionDetail,
        time: l10n.attentionSentToday,
        declineLabel: l10n.attentionDecline,
        approveLabel: l10n.attentionApprove,
        onDecline: () => _decline(context, l10n, _ApprovalKind.correction),
        onApprove: () => _approve(context, l10n, _ApprovalKind.correction),
      ),
      ApprovalRequestCard(
        key: const Key('approval-request-extra'),
        title: l10n.attentionExtraPickup,
        source: l10n.attentionAbcPlastic,
        detail: l10n.attentionExtraPickupDetail,
        time: l10n.attentionSent21Oct,
        declineLabel: l10n.attentionDecline,
        approveLabel: l10n.attentionApprove,
        onDecline: () => _decline(context, l10n, _ApprovalKind.extraPickup),
        onApprove: () => _approve(context, l10n, _ApprovalKind.extraPickup),
      ),
    ];
  }

  List<Widget> _doneCards(DriverLocalizations l10n) {
    Widget approved() => ApprovalStatusTag(
      status: ApprovalStatus.approved,
      label: l10n.attentionApproved,
    );
    return [
      ApprovalRequestCard(
        title: l10n.attentionCorrectionFromDriver,
        source: l10n.attentionHotelRajdhaniStop,
        detail: l10n.apCorrectionDoneDetail,
        time: l10n.apApprovedToday,
        tag: approved(),
      ),
      ApprovalRequestCard(
        title: l10n.attentionExtraPickup,
        source: l10n.attentionAbcPlastic,
        detail: l10n.apExtraPickupDoneDetail,
        time: l10n.apApproved21Oct,
        tag: approved(),
      ),
      ApprovalRequestCard(
        title: l10n.apStartPickupsFromIec,
        source: l10n.apGreenLeafNisha,
        detail: l10n.apDeclineReplyDetail,
        time: l10n.apDeclined20Oct,
        tag: ApprovalStatusTag(
          status: ApprovalStatus.declined,
          label: l10n.attentionDeclined,
        ),
      ),
    ];
  }

  Future<void> _decline(
    BuildContext context,
    DriverLocalizations l10n,
    _ApprovalKind kind,
  ) {
    final correction = kind == _ApprovalKind.correction;
    return showModuleSheet<bool>(
      context,
      builder: (_) => ApprovalDeclineSheet(
        title: correction
            ? l10n.apDeclineCorrectionTitle
            : l10n.apDeclineExtraTitle,
        message: correction
            ? l10n.apDeclineCorrectionBody
            : l10n.apDeclineExtraBody,
        initialReply: correction ? l10n.apDeclineCorrectionReply : '',
        hint: l10n.apReplyHint,
        confirmLabel: l10n.apDeclineAndReply,
        cancelLabel: l10n.apCancel,
      ),
    );
  }

  Future<void> _approve(
    BuildContext context,
    DriverLocalizations l10n,
    _ApprovalKind kind,
  ) {
    final correction = kind == _ApprovalKind.correction;
    return showModulePopup<void>(
      context,
      builder: (popupContext) => ApprovalSuccessPopup(
        title: correction
            ? l10n.attentionCorrectionApproved
            : l10n.apExtraApprovedTitle,
        message: correction
            ? l10n.attentionCorrectionApprovedMessage
            : l10n.apExtraApprovedBody,
        primaryLabel: l10n.attentionBackToApprovals,
        secondaryLabel: l10n.attentionBackToHome,
        onPrimary: () => Navigator.pop(popupContext),
        onSecondary: () {
          Navigator.pop(popupContext);
          Navigator.maybePop(context);
        },
      ),
    );
  }
}

class PickupSupervisorMyRequestsScreen extends StatefulWidget {
  const PickupSupervisorMyRequestsScreen({super.key});

  @override
  State<PickupSupervisorMyRequestsScreen> createState() =>
      _PickupSupervisorMyRequestsScreenState();
}

class _PickupSupervisorMyRequestsScreenState
    extends State<PickupSupervisorMyRequestsScreen> {
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

class PickupSupervisorSuggestionsScreen extends StatelessWidget {
  const PickupSupervisorSuggestionsScreen({super.key});

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
  const _AttentionHeader({this.title, this.subtitle});

  final String? title;
  final String? subtitle;

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
                padding: const EdgeInsets.all(10),
                child: SvgPicture.asset(
                  '$_assetRoot/back.svg',
                  package: _assetPackage,
                ),
              ),
            ),
          ),
        ),
        ...[
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: DriverTextStyles.medium12.copyWith(
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

class _WideButton extends StatelessWidget {
  const _WideButton({
    required this.label,
    required this.onPressed,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool outlined;

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
        backgroundColor: DriverColors.primary500,
        foregroundColor: Colors.white,
        shape: shape,
      ),
      child: Text(label, style: DriverTextStyles.semibold16),
    );
  }
}
