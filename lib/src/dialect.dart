import 'dart:async';

abstract class SqlPart {
  const SqlPart();

  void writeSqlPart(SqlWriter writer);

  SqlWithParams<T> toSql<T>([Dialect<T>? dialect]) {
    dialect ??= Dialect.getZoneDialect() ?? Dialect.getGlobalDialect();
    if (dialect == null) {
      throw ArgumentError('No Dialect provided.');
    }
    final writer = dialect.newSqlWriter();
    writeSqlPart(writer);
    return writer.complete();
  }
}

class SqlWithParams<T> {
  final String text;
  final T params;

  SqlWithParams(this.text, this.params);
}

const _dialectZoneKey = 'package:typed_sql/Dialect';

abstract class Dialect<T> {
  const Dialect();

  static Dialect? _global;
  static Dialect<T>? getGlobalDialect<T>() => _global as Dialect<T>?;
  static void setGlobalDialect(Dialect? dialect) {
    _global = dialect;
  }

  static R zoneWith<T, R>(Dialect<T> dialect, R Function() action) {
    return Zone.current.fork(zoneValues: {
      _dialectZoneKey: dialect,
    }).run(action);
  }

  static Dialect<T>? getZoneDialect<T>() {
    return Zone.current[_dialectZoneKey] as Dialect<T>?;
  }

  SqlWriter<T> newSqlWriter();

  String escapeParam(String key) => throw UnimplementedError();
}

class NamedDialect extends Dialect<Map<String, dynamic>> {
  const NamedDialect();

  @override
  SqlWriter<Map<String, dynamic>> newSqlWriter() => NamedSqlWriter(this);
}

class PostgresDialect extends NamedDialect {
  const PostgresDialect();

  @override
  String escapeParam(String key) => '@$key';
}

abstract class SqlWriter<T> {
  final Dialect dialect;
  final _sb = StringBuffer();
  final T _params;

  SqlWriter._(this.dialect, this._params);

  bool get isNotEmpty => _sb.isNotEmpty;

  void write(String value) {
    _sb.write(value);
  }

  void writeParam(dynamic value, {String? key});

  void writePartsJoined<P>(
    List<P> parts, {
    required String join,
    required void Function(P part) fn,
    String? partPrefix,
    String? partPostfix,
  }) {
    if (parts.length == 1) {
      fn(parts.single);
      return;
    }
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) {
        write(join);
      }
      if (partPrefix != null) {
        write(partPrefix);
      }
      fn(parts[i]);
      if (partPostfix != null) {
        write(partPostfix);
      }
    }
  }

  SqlWithParams<T> complete() {
    return SqlWithParams(_sb.toString(), _params);
  }
}

class NamedSqlWriter extends SqlWriter<Map<String, dynamic>> {
  final _counters = <String, int>{};

  NamedSqlWriter(Dialect dialect) : super._(dialect, <String, dynamic>{});

  @override
  void writeParam(dynamic value, {String? key}) {
    final prefix = key ?? 'p';
    var finalKey = prefix;
    while (_params.containsKey(finalKey) && _params[finalKey] != value) {
      final count = (_counters[key] ?? 0) + 1;
      finalKey = '${prefix}_$count';
    }
    _params[finalKey] = value;
    write(dialect.escapeParam(finalKey));
  }
}
