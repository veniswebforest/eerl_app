import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/core/widgets/module_dashed_line.dart';

abstract final class StopDetailAssets {
  static const package = 'pickup_supervisor';
  static const _i = 'assets/icons/stop_detail';

  static const skipSource = '$_i/skip_source.svg';
  static const check = '$_i/check.svg';
  static const outcomePending = '$_i/outcome_pending.svg';
  static const outcomeNext = '$_i/outcome_next.svg';
  static const outcomeCollected = '$_i/outcome_collected.svg';
  static const outcomeZero = '$_i/outcome_zero.svg';
  static const outcomeMissed = '$_i/outcome_missed.svg';
  static const outcomeCancelled = '$_i/outcome_cancelled.svg';
  static const outcomePaused = '$_i/outcome_paused.svg';
  static const tagApp = '$_i/tag_app.svg';
  static const tagLocation = '$_i/tag_location.svg';
  static const tagGate = 'assets/icons/route_detail/tag_gate.svg';
  static const voicePlay = '$_i/voice_play.svg';
  static const camera = '$_i/camera.svg';
  static const add = '$_i/add_green.svg';
  static const callWhite = '$_i/call_white.svg';
  static const restart = '$_i/play_green.svg';
  static const calendar = 'assets/icons/supervisor/home/attention.svg';
  static const callOutline = '$_i/call_outline.svg';
}

Widget stopDetailIcon(String asset, double size) => SvgPicture.asset(
  asset,
  package: StopDetailAssets.package,
  width: size,
  height: size,
);

/// Label over value, as in the stop detail cards.
class StopLabelValue extends StatelessWidget {
  const StopLabelValue({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: DriverTextStyles.medium12.copyWith(
          color: DriverColors.mutedText,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        value,
        style: DriverTextStyles.semibold14.copyWith(
          color: DriverColors.neutral950,
        ),
      ),
    ],
  );
}

/// White card: stop name with its frequency tag and label/value rows.
class StopInfoCard extends StatelessWidget {
  const StopInfoCard({
    super.key,
    required this.title,
    required this.rows,
    this.frequency,
  });

  final String title;
  final String? frequency;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: DriverColors.neutral50,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: DriverColors.shadow,
          blurRadius: 5,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: DriverTextStyles.semibold18.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ),
            if (frequency != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: DriverColors.slate50,
                  borderRadius: BorderRadius.circular(48),
                ),
                child: Text(
                  frequency!,
                  style: DriverTextStyles.semibold12.copyWith(
                    color: DriverColors.neutral700,
                  ),
                ),
              ),
            ],
          ],
        ),
        for (final r in rows) ...[
          const SizedBox(height: 12),
          StopLabelValue(label: r.$1, value: r.$2),
        ],
      ],
    ),
  );
}

enum StopOutcomeTone {
  pending,
  next,
  collected,
  zero,
  missed,
  cancelled,
  paused,
}

/// Background, border, title colour and icon of each outcome card.
({Color bg, Color border, Color fg, String icon}) stopOutcomeStyle(
  StopOutcomeTone tone,
) => switch (tone) {
  StopOutcomeTone.pending => (
    bg: DriverColors.outcomePendingBg,
    border: DriverColors.outcomePendingBorder,
    fg: DriverColors.outcomePendingText,
    icon: StopDetailAssets.outcomePending,
  ),
  StopOutcomeTone.next => (
    bg: DriverColors.outcomeNextBg,
    border: DriverColors.outcomeNextBorder,
    fg: DriverColors.outcomeNextText,
    icon: StopDetailAssets.outcomeNext,
  ),
  StopOutcomeTone.collected => (
    bg: DriverColors.outcomeNextBg,
    border: DriverColors.outcomeNextBorder,
    fg: DriverColors.outcomeNextText,
    icon: StopDetailAssets.outcomeCollected,
  ),
  StopOutcomeTone.zero => (
    bg: DriverColors.stopZeroBackground,
    border: DriverColors.stopZeroBorder,
    fg: DriverColors.slate600,
    icon: StopDetailAssets.outcomeZero,
  ),
  StopOutcomeTone.missed => (
    bg: DriverColors.missedCard,
    border: DriverColors.missedCardBorder,
    fg: DriverColors.red600,
    icon: StopDetailAssets.outcomeMissed,
  ),
  StopOutcomeTone.cancelled => (
    bg: DriverColors.stopCancelledBackground,
    border: DriverColors.stopCancelledBorder,
    fg: DriverColors.purple600,
    icon: StopDetailAssets.outcomeCancelled,
  ),
  StopOutcomeTone.paused => (
    bg: DriverColors.stopInactiveBackground,
    border: DriverColors.stopInactiveBorder,
    fg: DriverColors.slate600,
    icon: StopDetailAssets.outcomePaused,
  ),
};

/// Tinted outcome card: icon and title, then [children] (record rows).
class StopOutcomeCard extends StatelessWidget {
  const StopOutcomeCard({
    super.key,
    required this.tone,
    required this.title,
    required this.children,
    this.gap = 12,
  });

  final StopOutcomeTone tone;
  final String title;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final style = stopOutcomeStyle(tone);
    return Container(
      key: Key('stop-outcome-${tone.name}'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: style.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              stopDetailIcon(style.icon, 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: DriverTextStyles.bold16.copyWith(color: style.fg),
                ),
              ),
            ],
          ),
          for (final child in children) ...[SizedBox(height: gap), child],
        ],
      ),
    );
  }
}

/// Amber "Pending" or green "Next stop" box with Due / On the trip rows.
class StopOutcomeBox extends StatelessWidget {
  const StopOutcomeBox({
    super.key,
    required this.title,
    required this.rows,
    this.next = false,
  });

  final String title;
  final List<(String, String)> rows;
  final bool next;

  @override
  Widget build(BuildContext context) => StopOutcomeCard(
    key: Key(next ? 'stop-outcome-next' : 'stop-outcome-pending'),
    tone: next ? StopOutcomeTone.next : StopOutcomeTone.pending,
    title: title,
    children: [for (final r in rows) StopLabelValue(label: r.$1, value: r.$2)],
  );
}

/// Label, value and optional extras (tags, voice note) under it.
class StopRecordRow extends StatelessWidget {
  const StopRecordRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.extras = const [],
    this.muted = false,
  });

  final String label;

  /// Regular grey value ("Not recorded …").
  final bool muted;
  final String? value;
  final Widget? valueWidget;
  final List<Widget> extras;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: DriverTextStyles.medium12.copyWith(
          color: DriverColors.mutedText,
        ),
      ),
      const SizedBox(height: 4),
      ?valueWidget,
      if (value != null)
        Text(
          value!,
          style: muted
              ? DriverTextStyles.regular14.copyWith(
                  color: DriverColors.slate600,
                )
              : DriverTextStyles.semibold14.copyWith(
                  color: DriverColors.neutral950,
                ),
        ),
      for (final e in extras) ...[const SizedBox(height: 6), e],
    ],
  );
}

/// White pill with an icon: "Entered in the app", "Location matched", or the
/// amber "Entered at gate".
class StopRecordTag extends StatelessWidget {
  const StopRecordTag({
    super.key,
    required this.icon,
    required this.label,
    this.amber = false,
  });

  final String icon;
  final String label;
  final bool amber;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: amber ? DriverColors.escalatedBg : DriverColors.neutral50,
      borderRadius: BorderRadius.circular(48),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        stopDetailIcon(icon, 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: DriverTextStyles.semibold12.copyWith(
            color: amber ? DriverColors.amber800 : DriverColors.primary500,
          ),
        ),
      ],
    ),
  );
}

/// Blue voice-note pill: play button, waveform and duration (static).
class StopVoiceNote extends StatelessWidget {
  const StopVoiceNote({super.key, required this.duration, this.expand = false});

  final String duration;

  /// Full width (0 kg card) or hugging its content.
  final bool expand;

  static const _bars = <double>[
    6,
    12,
    18,
    10,
    14,
    20,
    8,
    16,
    12,
    6,
    14,
    18,
    10,
    8,
    12,
    16,
    6,
    10,
  ];

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
      decoration: BoxDecoration(
        color: DriverColors.secondary100,
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: DriverColors.blue600,
              shape: BoxShape.circle,
            ),
            child: stopDetailIcon(StopDetailAssets.voicePlay, 14),
          ),
          const SizedBox(width: 10),
          for (final (i, h) in _bars.indexed) ...[
            if (i > 0) const SizedBox(width: 3),
            Container(
              width: 3,
              height: h,
              decoration: BoxDecoration(
                color: DriverColors.blue600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          const SizedBox(width: 10),
          Text(
            duration,
            style: DriverTextStyles.semibold12.copyWith(
              color: DriverColors.blue600,
            ),
          ),
        ],
      ),
    );
    if (expand) return pill;
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: pill,
    );
  }
}

/// Grey "Photo from the driver" placeholder.
class StopPhotoPlaceholder extends StatelessWidget {
  const StopPhotoPlaceholder({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: DriverColors.cool200,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        stopDetailIcon(StopDetailAssets.camera, 20),
        const SizedBox(width: 8),
        Text(
          label,
          style: DriverTextStyles.medium12.copyWith(
            color: DriverColors.slate600,
          ),
        ),
      ],
    ),
  );
}

/// Full-width 48px action: outlined green (default) or filled green, with an
/// icon (Call, Add an extra pickup, Ask to restart pickups, Call the driver).
class StopActionButton extends StatelessWidget {
  const StopActionButton({
    super.key,
    required this.label,
    required this.icon,
    this.filled = false,
    this.onPressed,
  });

  final String label;
  final String icon;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? DriverColors.neutral50 : DriverColors.primary500;
    return SizedBox(
      height: 48,
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed ?? () {},
        style: TextButton.styleFrom(
          backgroundColor: filled
              ? DriverColors.primary500
              : DriverColors.neutral50,
          foregroundColor: fg,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: filled
                ? BorderSide.none
                : const BorderSide(color: DriverColors.primary500),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            stopDetailIcon(icon, 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: DriverTextStyles.bold14.copyWith(
                  fontSize: 15,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

BoxDecoration _whiteCard() => BoxDecoration(
  color: DriverColors.neutral50,
  borderRadius: BorderRadius.circular(12),
  boxShadow: const [
    BoxShadow(color: DriverColors.shadow, blurRadius: 4, offset: Offset(0, 2)),
  ],
);

/// "Collected items": each material with its amount box and photos.
class StopCollectedItemsCard extends StatelessWidget {
  const StopCollectedItemsCard({
    super.key,
    required this.title,
    required this.collectedLabel,
    required this.items,
  });

  final String title;
  final String collectedLabel;

  /// (name, unit label, amount, thumb, photos, is pieces)
  final List<(String, String, String, String, List<String>, bool)> items;

  @override
  Widget build(BuildContext context) {
    Widget image(String asset, double w, double h) => ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.asset(
        asset,
        package: StopDetailAssets.package,
        width: w,
        height: h,
        fit: BoxFit.cover,
      ),
    );
    return Container(
      key: const Key('stop-collected-items'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: DriverTextStyles.semibold16.copyWith(
              color: DriverColors.neutral600,
            ),
          ),
          for (final it in items) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                image(it.$4, 40, 40),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    it.$6 ? '${it.$1}  •  ${it.$2}' : it.$1,
                    style:
                        (it.$6
                                ? DriverTextStyles.semibold14
                                : DriverTextStyles.bold14)
                            .copyWith(color: DriverColors.cool950),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              collectedLabel,
              style: DriverTextStyles.medium14.copyWith(
                color: DriverColors.neutral950,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: DriverColors.cool200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    it.$2,
                    style: DriverTextStyles.semibold16.copyWith(
                      color: DriverColors.neutral950,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    it.$3,
                    style: DriverTextStyles.regular14.copyWith(
                      color: DriverColors.neutral950,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const ModuleDashedLine(color: DriverColors.cool400),
            const SizedBox(height: 12),
            Row(
              children: [
                for (final (i, photo) in it.$5.indexed) ...[
                  if (i > 0) const SizedBox(width: 12),
                  image(photo, 109, 70),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: DriverColors.cool600),
          ],
        ],
      ),
    );
  }
}

/// KG / PCS totals card.
class StopTotalsCard extends StatelessWidget {
  const StopTotalsCard({super.key, required this.blocks});

  /// (block title, "Total Collected", value)
  final List<(String, String, String)> blocks;

  @override
  Widget build(BuildContext context) => Container(
    key: const Key('stop-totals'),
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _whiteCard(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (i, b) in blocks.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          Text(
            b.$1,
            style: DriverTextStyles.bold14.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  b.$2,
                  style: DriverTextStyles.semibold14.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              Text(
                b.$3,
                style: DriverTextStyles.bold16.copyWith(
                  color: DriverColors.neutral950,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const ModuleDashedLine(color: DriverColors.primary800),
        ],
      ],
    ),
  );
}
