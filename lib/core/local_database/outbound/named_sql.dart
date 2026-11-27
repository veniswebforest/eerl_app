/// Binds `:name` parameters, as the outbound SQLite doc writes them, to
/// sqflite's positional `?` arguments.
///
/// Every `:identifier` outside a quoted literal becomes `?`, and its value is
/// appended in order, so a name used twice is bound twice. Text inside single
/// quotes (`'%H:%M'`, `'+5 hours'`) and double quotes is left alone, as is the
/// `::` sequence. A name missing from [params] is an error, so a typo can never
/// silently bind NULL.
class NamedSql {
  const NamedSql._(this.sql, this.arguments);

  final String sql;
  final List<Object?> arguments;

  static final Map<String, _Parsed> _cache = {};

  factory NamedSql(String source, Map<String, Object?> params) {
    final parsed = _cache.putIfAbsent(source, () => _parse(source));
    final arguments = <Object?>[];
    for (final name in parsed.names) {
      if (!params.containsKey(name)) {
        throw ArgumentError.value(
          name,
          'params',
          'Missing SQL parameter :$name',
        );
      }
      arguments.add(params[name]);
    }
    return NamedSql._(parsed.sql, arguments);
  }

  static _Parsed _parse(String source) {
    final out = StringBuffer();
    final names = <String>[];
    var index = 0;
    String? quote;
    while (index < source.length) {
      final char = source[index];
      if (quote != null) {
        out.write(char);
        if (char == quote) {
          // A doubled quote inside a literal stays inside it.
          if (index + 1 < source.length && source[index + 1] == quote) {
            out.write(source[index + 1]);
            index += 2;
            continue;
          }
          quote = null;
        }
        index++;
        continue;
      }
      if (char == "'" || char == '"') {
        quote = char;
        out.write(char);
        index++;
        continue;
      }
      if (char == '-' &&
          index + 1 < source.length &&
          source[index + 1] == '-') {
        // A line comment: copy it through untouched.
        final end = source.indexOf('\n', index);
        final stop = end == -1 ? source.length : end;
        out.write(source.substring(index, stop));
        index = stop;
        continue;
      }
      if (char == ':' &&
          index + 1 < source.length &&
          _isNameStart(source.codeUnitAt(index + 1)) &&
          (index == 0 || source[index - 1] != ':')) {
        var end = index + 1;
        while (end < source.length && _isNamePart(source.codeUnitAt(end))) {
          end++;
        }
        names.add(source.substring(index + 1, end));
        out.write('?');
        index = end;
        continue;
      }
      out.write(char);
      index++;
    }
    return _Parsed(out.toString(), List.unmodifiable(names));
  }

  static bool _isNameStart(int code) =>
      (code >= 65 && code <= 90) || (code >= 97 && code <= 122) || code == 95;

  static bool _isNamePart(int code) =>
      _isNameStart(code) || (code >= 48 && code <= 57);
}

class _Parsed {
  const _Parsed(this.sql, this.names);

  final String sql;
  final List<String> names;
}
