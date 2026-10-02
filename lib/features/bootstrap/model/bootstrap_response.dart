class BootstrapResponse {
  const BootstrapResponse({required this.data});

  final BootstrapData data;

  factory BootstrapResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    if (rawData is! Map) {
      throw const FormatException('Bootstrap response is missing data');
    }
    return BootstrapResponse(
      data: BootstrapData.fromJson(Map<String, dynamic>.from(rawData)),
    );
  }
}

class BootstrapData {
  const BootstrapData({
    required this.cursor,
    required this.hasMore,
    required this.full,
    required this.serverTime,
    required this.me,
    required this.tables,
  });

  final String cursor;
  final bool hasMore;
  final bool full;
  final String? serverTime;
  final BootstrapMe? me;

  /// Presence in this map is meaningful: a missing table means no change.
  final Map<String, BootstrapTableChange> tables;

  factory BootstrapData.fromJson(Map<String, dynamic> json) {
    final cursor = json['cursor'];
    if (cursor is! String || cursor.isEmpty) {
      throw const FormatException('Bootstrap response has an invalid cursor');
    }

    final rawMe = json['me'];
    final rawTables = json['tables'];
    final tables = <String, BootstrapTableChange>{};
    if (rawTables is Map) {
      for (final entry in rawTables.entries) {
        if (entry.value is Map) {
          tables[entry.key.toString()] = BootstrapTableChange.fromJson(
            Map<String, dynamic>.from(entry.value as Map),
          );
        }
      }
    }

    return BootstrapData(
      cursor: cursor,
      hasMore: json['hasMore'] == true,
      full: json['full'] == true,
      serverTime: json['serverTime'] as String?,
      me: rawMe is Map
          ? BootstrapMe.fromJson(Map<String, dynamic>.from(rawMe))
          : null,
      tables: Map.unmodifiable(tables),
    );
  }
}

class BootstrapMe {
  const BootstrapMe({
    required this.scopeKey,
    required this.user,
    required this.roles,
    required this.centers,
    required this.supervisor,
    required this.session,
  });

  final String? scopeKey;
  final BootstrapUser? user;
  final List<BootstrapRole> roles;
  final List<BootstrapCenter> centers;
  final BootstrapSupervisor? supervisor;
  final BootstrapSession? session;

  factory BootstrapMe.fromJson(Map<String, dynamic> json) {
    final rawUser = json['user'];
    final rawSupervisor = json['supervisor'];
    final rawSession = json['session'];
    return BootstrapMe(
      scopeKey: json['scopeKey'] as String?,
      user: rawUser is Map
          ? BootstrapUser.fromJson(Map<String, dynamic>.from(rawUser))
          : null,
      roles: _mapList(json['roles'], BootstrapRole.fromJson),
      centers: _mapList(json['centers'], BootstrapCenter.fromJson),
      supervisor: rawSupervisor is Map
          ? BootstrapSupervisor.fromJson(
              Map<String, dynamic>.from(rawSupervisor),
            )
          : null,
      session: rawSession is Map
          ? BootstrapSession.fromJson(Map<String, dynamic>.from(rawSession))
          : null,
    );
  }
}

class BootstrapUser {
  const BootstrapUser({this.id, this.name, this.phone, this.photoUrl});

  final String? id;
  final String? name;
  final String? phone;
  final String? photoUrl;

  factory BootstrapUser.fromJson(Map<String, dynamic> json) => BootstrapUser(
    id: json['id'] as String?,
    name: json['name'] as String?,
    phone: json['phone'] as String?,
    photoUrl: json['photoUrl'] as String?,
  );
}

class BootstrapRole {
  const BootstrapRole({required this.key, required this.name, this.modules});

  final String? key;
  final String? name;
  final List<Object?>? modules;

  factory BootstrapRole.fromJson(Map<String, dynamic> json) {
    final rawModules = json['modules'];
    return BootstrapRole(
      key: json['key'] as String?,
      name: json['name'] as String?,
      modules: rawModules is List ? List<Object?>.from(rawModules) : null,
    );
  }
}

class BootstrapCenter {
  const BootstrapCenter({
    required this.id,
    required this.isPrimary,
    required this.agentNumber,
    required this.slipCounter,
  });

  final String? id;
  final bool isPrimary;
  final int? agentNumber;
  final BootstrapSlipCounter? slipCounter;

  factory BootstrapCenter.fromJson(Map<String, dynamic> json) {
    final rawSlipCounter = json['slipCounter'];
    return BootstrapCenter(
      id: json['id'] as String?,
      isPrimary: json['isPrimary'] == true,
      agentNumber: (json['agentNumber'] as num?)?.toInt(),
      slipCounter: rawSlipCounter is Map
          ? BootstrapSlipCounter.fromJson(
              Map<String, dynamic>.from(rawSlipCounter),
            )
          : null,
    );
  }
}

class BootstrapSlipCounter {
  const BootstrapSlipCounter({required this.date, required this.lastCount});

  final String? date;
  final int lastCount;

  factory BootstrapSlipCounter.fromJson(Map<String, dynamic> json) =>
      BootstrapSlipCounter(
        date: json['date'] as String?,
        lastCount: (json['lastCount'] as num?)?.toInt() ?? 0,
      );
}

class BootstrapSupervisor {
  const BootstrapSupervisor({this.name, this.phone});

  final String? name;
  final String? phone;

  factory BootstrapSupervisor.fromJson(Map<String, dynamic> json) =>
      BootstrapSupervisor(
        name: json['name'] as String?,
        phone: json['phone'] as String?,
      );
}

class BootstrapSession {
  const BootstrapSession({this.expiresAt});

  final String? expiresAt;

  factory BootstrapSession.fromJson(Map<String, dynamic> json) =>
      BootstrapSession(expiresAt: json['expiresAt'] as String?);
}

class BootstrapTableChange {
  const BootstrapTableChange({
    required this.hasReplace,
    required this.hasUpserts,
    required this.hasDeletes,
    required this.replace,
    required this.upserts,
    required this.deletes,
  });

  final bool hasReplace;
  final bool hasUpserts;
  final bool hasDeletes;
  final List<Map<String, Object?>> replace;
  final List<Map<String, Object?>> upserts;
  final List<String> deletes;

  factory BootstrapTableChange.fromJson(Map<String, dynamic> json) =>
      BootstrapTableChange(
        hasReplace: json.containsKey('replace'),
        hasUpserts: json.containsKey('upserts'),
        hasDeletes: json.containsKey('deletes'),
        replace: _databaseRows(json['replace']),
        upserts: _databaseRows(json['upserts']),
        deletes: _stringList(json['deletes']),
      );
}

List<T> _mapList<T>(Object? value, T Function(Map<String, dynamic>) mapper) {
  if (value is! List) return <T>[];
  return value
      .whereType<Map>()
      .map((item) => mapper(Map<String, dynamic>.from(item)))
      .toList(growable: false);
}

List<Map<String, Object?>> _databaseRows(Object? value) {
  if (value is! List) return <Map<String, Object?>>[];
  return value
      .whereType<Map>()
      .map((row) => Map<String, Object?>.from(row))
      .toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List) return <String>[];
  return value.whereType<String>().toList(growable: false);
}
