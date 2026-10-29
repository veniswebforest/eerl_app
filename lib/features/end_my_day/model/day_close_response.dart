class DayCloseResponse {
  const DayCloseResponse({required this.data});

  final DayCloseData data;

  factory DayCloseResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Day-close response is missing data');
    }
    return DayCloseResponse(
      data: DayCloseData.fromJson(Map<String, dynamic>.from(rawData)),
    );
  }
}

class DayCloseData {
  const DayCloseData({
    required this.centerId,
    required this.date,
    required this.lockTime,
    required this.canClose,
    required this.openDrafts,
    required this.summary,
    this.blockedReason,
    this.closedAt,
    this.closedBy,
    this.shareText,
  });

  final String centerId;
  final String date;
  final String? lockTime;
  final bool canClose;
  final String? blockedReason;
  final int openDrafts;
  final DayCloseSummary summary;
  final String? closedAt;
  final String? closedBy;
  final String? shareText;

  factory DayCloseData.fromJson(Map<String, dynamic> json) => DayCloseData(
    centerId: json['centerId']?.toString() ?? '',
    date: json['date']?.toString() ?? '',
    lockTime: json['lockTime']?.toString(),
    canClose: json['canClose'] == true,
    blockedReason: json['blockedReason']?.toString(),
    openDrafts: _integer(json['openDrafts']),
    summary: DayCloseSummary.fromJson(_map(json['summary'])),
    closedAt: json['closedAt']?.toString(),
    closedBy: json['closedBy']?.toString(),
    shareText: json['shareText']?.toString(),
  );
}

class DayCloseSummary {
  const DayCloseSummary({
    required this.wallet,
    required this.collections,
    required this.expenses,
  });

  final DayCloseWalletSummary wallet;
  final DayCloseCollectionsSummary collections;
  final DayCloseExpensesSummary expenses;

  factory DayCloseSummary.fromJson(Map<String, dynamic> json) =>
      DayCloseSummary(
        wallet: DayCloseWalletSummary.fromJson(_map(json['wallet'])),
        collections: DayCloseCollectionsSummary.fromJson(
          _map(json['collections']),
        ),
        expenses: DayCloseExpensesSummary.fromJson(_map(json['expenses'])),
      );
}

class DayCloseWalletSummary {
  const DayCloseWalletSummary({
    required this.opening,
    required this.topUps,
    required this.collectionPayments,
    required this.expenses,
    required this.closing,
  });

  final double opening;
  final double topUps;
  final double collectionPayments;
  final double expenses;
  final double closing;

  factory DayCloseWalletSummary.fromJson(Map<String, dynamic> json) =>
      DayCloseWalletSummary(
        opening: _number(json['opening']),
        topUps: _number(json['topUps']),
        collectionPayments: _number(json['collectionPayments']),
        expenses: _number(json['expenses']),
        closing: _number(json['closing']),
      );
}

class DayCloseCollectionsSummary {
  const DayCloseCollectionsSummary({
    required this.total,
    required this.pendingReview,
    required this.rejected,
    required this.byUnit,
  });

  final int total;
  final int pendingReview;
  final int rejected;
  final List<DayCloseCollectionUnit> byUnit;

  factory DayCloseCollectionsSummary.fromJson(Map<String, dynamic> json) {
    final rawUnits = json['byUnit'];
    return DayCloseCollectionsSummary(
      total: _integer(json['total']),
      pendingReview: _integer(json['pendingReview']),
      rejected: _integer(json['rejected']),
      byUnit: rawUnits is List
          ? rawUnits
                .whereType<Map>()
                .map(
                  (item) => DayCloseCollectionUnit.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList(growable: false)
          : const [],
    );
  }
}

class DayCloseCollectionUnit {
  const DayCloseCollectionUnit({
    required this.unit,
    required this.quantity,
    this.unitName,
    this.verifiedQty,
  });

  final String unit;
  final double quantity;
  final String? unitName;
  final double? verifiedQty;

  double get effectiveQuantity => verifiedQty ?? quantity;

  factory DayCloseCollectionUnit.fromJson(Map<String, dynamic> json) {
    final rawUnit = json['unit'];
    final String unitCode;
    final String? unitName;
    if (rawUnit is Map) {
      unitCode = rawUnit['code']?.toString() ??
          rawUnit['unit']?.toString() ??
          rawUnit['name']?.toString() ??
          '';
      unitName = rawUnit['name']?.toString();
    } else {
      unitCode = rawUnit?.toString() ?? '';
      unitName = null;
    }

    final verified = json.containsKey('verifiedQty') && json['verifiedQty'] != null
        ? _number(json['verifiedQty'])
        : null;
    final qty = _number(
      json['verifiedQty'] ?? json['quantity'] ?? json['qty'],
    );

    return DayCloseCollectionUnit(
      unit: unitCode,
      quantity: qty,
      unitName: unitName,
      verifiedQty: verified,
    );
  }
}

class DayCloseExpensesSummary {
  const DayCloseExpensesSummary({required this.count, required this.amount});

  final int count;
  final double amount;

  factory DayCloseExpensesSummary.fromJson(Map<String, dynamic> json) =>
      DayCloseExpensesSummary(
        count: _integer(json['count']),
        amount: _number(json['amount']),
      );
}

class DayCloseScreenData {
  const DayCloseScreenData({
    required this.dayClose,
    required this.pendingSyncCount,
    this.eodLockTime,
  });

  final DayCloseData dayClose;
  final int pendingSyncCount;
  final String? eodLockTime;

  String? get effectiveLockTime {
    final centerLockTime = eodLockTime?.trim();
    if (centerLockTime != null && _validClockTime(centerLockTime)) {
      return centerLockTime;
    }
    final apiLockTime = dayClose.lockTime?.trim();
    if (apiLockTime != null && _validClockTime(apiLockTime)) {
      return apiLockTime;
    }
    return null;
  }
}

bool _validClockTime(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(value);
  if (match == null) return false;
  final hour = int.tryParse(match.group(1)!);
  final minute = int.tryParse(match.group(2)!);
  final second = int.tryParse(match.group(3) ?? '0');
  return hour != null &&
      minute != null &&
      second != null &&
      hour <= 23 &&
      minute <= 59 &&
      second <= 59;
}

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

double _number(Object? value) => value is num
    ? value.toDouble()
    : double.tryParse(value?.toString() ?? '') ?? 0;

int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
