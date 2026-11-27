import 'dart:math' as math;

import 'dart:io';

import 'package:eerl_app/core/local_database/app_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pickup_supervisor/core/data/outbound_live_session.dart';
import 'package:pickup_supervisor/features/driver/data/driver_live_data.dart';
import 'package:pickup_supervisor/features/driver/model/driver_pickup_stop.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pickup_supervisor/core/theme/driver_colors.dart';
import 'package:pickup_supervisor/core/theme/driver_text_styles.dart';
import 'package:pickup_supervisor/features/driver/view/driver_collection_correction_screen.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_dashboard_widgets.dart';
import 'package:pickup_supervisor/features/driver/widgets/driver_stops_widgets.dart';
import 'package:pickup_supervisor/l10n/driver_localization_scope.dart';
import 'package:pickup_supervisor/l10n/generated/driver_localizations.dart';

const _package = 'pickup_supervisor';
const _homeAssets = 'assets/icons/driver/home_v2';
const _stopAssets = 'assets/icons/driver/stops_v2';
const _stopImages = 'assets/images/driver/stops_v2';

class DriverCollectedStopDetailScreen extends StatelessWidget {
  const DriverCollectedStopDetailScreen({super.key, this.stopId});

  /// The live stop; null shows the design preview.
  final String? stopId;

  @override
  Widget build(BuildContext context) {
    final id = stopId;
    return DriverLocalizationScope(
      child: id == null
          ? const _CollectedStopDetailView()
          : OutboundLiveBuilder<_LiveRecord?>(
              load: (session) => _LiveRecord.load(session, id),
              fallback: const _CollectedStopDetailView(),
              builder: (context, data, _) =>
                  _CollectedStopDetailView(live: data),
            ),
    );
  }
}

/// A saved stop, read-only (outbound doc, Driver screens · Collection
/// record): what was saved, when, and its photos.
class _LiveRecord {
  const _LiveRecord(this.stop, this.photos, this.correctionRequested);

  final DriverStopLive stop;

  /// Local file paths or server URLs.
  final List<String> photos;
  final bool correctionRequested;

  static Future<_LiveRecord?> load(
    OutboundLiveSession session,
    String id,
  ) async {
    final row = await session.queries.driverStop(id);
    if (row == null) return null;
    final stop = DriverStopLive.fromRow(row, totalStops: 0);
    final photos = <String>[];
    for (final ref in stop.photoUrls) {
      if (ref.startsWith('http')) {
        photos.add(ref);
        continue;
      }
      final rows = await AppDatabase.instance.query(
        'photos',
        columns: const ['local_path', 'remote_url'],
        where: 'id = ?',
        whereArgs: [ref],
      );
      final path = rows.isEmpty
          ? null
          : (rows.single['local_path'] ?? rows.single['remote_url']) as String?;
      if (path != null) photos.add(path);
    }
    return _LiveRecord(
      stop,
      photos,
      await session.queries.correctionRequested(id),
    );
  }
}

class _CollectedStopDetailView extends StatelessWidget {
  const _CollectedStopDetailView({this.live});

  final _LiveRecord? live;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    final topInset = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: DriverColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final pageWidth = math.min(constraints.maxWidth, 480.0);
            return Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: pageWidth,
                height: constraints.maxHeight,
                child: CustomScrollView(
                  key: const Key('driver-collected-stop-detail'),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        topInset + 18,
                        20,
                        math.max(MediaQuery.paddingOf(context).bottom, 20),
                      ),
                      sliver: SliverList.list(
                        children: [
                          DriverStopsPageHeader(
                            title: l10n.stopTwoCollection,
                            backAsset: '$_stopAssets/back.svg',
                            onBack: () => Navigator.of(context).pop(),
                          ),
                          const SizedBox(height: 24),
                          _CollectionStatusCard(live: live),
                          const SizedBox(height: 16),
                          _SavedWeightCard(live: live?.stop),
                          const SizedBox(height: 16),
                          _PhotosCard(photos: live?.photos),
                          const SizedBox(height: 16),
                          DriverPrimaryButton(
                            label: l10n.askSupervisorToCorrect,
                            radius: 12,
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    const DriverCollectionCorrectionScreen(),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.savedCollectionReadonlyMessage,
                            style: DriverTextStyles.medium12.copyWith(
                              color: DriverColors.neutral500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CollectionStatusCard extends StatelessWidget {
  const _CollectionStatusCard({this.live});

  final _LiveRecord? live;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  live != null
                      ? l10n.stopCardTitle(
                          live!.stop.sourceName,
                          live!.stop.pickupType == DriverPickupType.sorted
                              ? l10n.sortedMaterial
                              : l10n.mixedMaterial,
                        )
                      : l10n.stopCardTitle(
                          l10n.hotelRajdhani,
                          l10n.sortedMaterial,
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.semibold16.copyWith(
                    color: DriverColors.neutral950,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: DriverColors.primary50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SvgPicture.asset(
                      '$_homeAssets/check.svg',
                      package: _package,
                      width: 16,
                      height: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.collectedLabel,
                      style: DriverTextStyles.semibold12.copyWith(
                        color: DriverColors.primary500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SvgPicture.asset(
                '$_stopAssets/saved_truck.svg',
                package: _package,
                width: 18,
                height: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  live != null ? _savedAt(context, live!.stop) : l10n.savedAt,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DriverTextStyles.medium14.copyWith(
                    color: DriverColors.neutral900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _savedAt(BuildContext context, DriverStopLive stop) {
  final at = DateTime.tryParse(stop.recordedAt ?? '');
  if (at == null) return '';
  final ist = at.toUtc().add(const Duration(hours: 5, minutes: 30));
  return DateFormat('d MMM, h:mm a').format(ist);
}

class _SavedWeightCard extends StatelessWidget {
  const _SavedWeightCard({this.live});

  final DriverStopLive? live;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.whatYouSaved,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            live != null
                ? l10n.liveKg(formatKg(_kg(live!)))
                : l10n.hotelRajdhaniWeight,
            style: DriverTextStyles.bold24.copyWith(
              color: DriverColors.neutral950,
            ),
          ),
          const SizedBox(height: 8),
          if (live == null) ...[
            _MaterialRow(l10n.petBottles, l10n.petBottlesWeight),
            _MaterialRow(l10n.cardboard, l10n.cardboardWeight),
          ] else
            for (final line in live!.entryLines.whereType<Map>())
              _MaterialRow(
                '${line['item_name'] ?? ''}',
                '${formatKg((line['quantity'] as num?)?.toDouble() ?? 0)} '
                    '${line['unit'] == 'KG' ? 'kg' : 'pcs'}',
              ),
        ],
      ),
    );
  }
}

double _kg(DriverStopLive stop) {
  if (stop.totalKg != null) return stop.totalKg!;
  var total = 0.0;
  for (final line in stop.entryLines.whereType<Map>()) {
    if (line['unit'] == 'KG') {
      total += (line['quantity'] as num?)?.toDouble() ?? 0;
    }
  }
  return total;
}

class _MaterialRow extends StatelessWidget {
  const _MaterialRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: DriverColors.cool300)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: DriverTextStyles.semibold14.copyWith(
            color: DriverColors.neutral950,
          ),
        ),
      ],
    ),
  );
}

class _PhotosCard extends StatelessWidget {
  const _PhotosCard({this.photos});

  /// Live photos (paths or URLs); null shows the design samples.
  final List<String>? photos;

  @override
  Widget build(BuildContext context) {
    final l10n = DriverLocalizations.of(context);
    return DriverSurfaceCard(
      radius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.photosMaterialScale,
            style: DriverTextStyles.medium14.copyWith(
              color: DriverColors.neutral700,
            ),
          ),
          const SizedBox(height: 12),
          if (photos == null)
            Row(
              children: const [
                _Photo('$_stopImages/material.png'),
                SizedBox(width: 12),
                _Photo('$_stopImages/scale.png'),
              ],
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final photo in photos!)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: photo.startsWith('http')
                        ? Image.network(
                            photo,
                            width: 109,
                            height: 70,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(photo),
                            width: 109,
                            height: 70,
                            fit: BoxFit.cover,
                          ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Photo extends StatelessWidget {
  const _Photo(this.asset);
  final String asset;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(6),
    child: Image.asset(
      asset,
      package: _package,
      width: 109,
      height: 70,
      fit: BoxFit.cover,
    ),
  );
}
