class ParameterizedQuery<T> {
  final String text;
  final T params;

  ParameterizedQuery(this.text, this.params);
}

abstract class Dialect<T> {
  const Dialect();

  ParameterizedQueryBuilder<T> newQueryBuilder();

  String namedParameter(String key) => throw UnimplementedError();
}

class PostgresDialect extends Dialect<Map<String, dynamic>> {
  const PostgresDialect();

  @override
  ParameterizedQueryBuilder<Map<String, dynamic>> newQueryBuilder() =>
      NamedParameterizedQueryBuilder(this);

  @override
  String namedParameter(String key) => '@$key';
}

abstract class ParameterizedQueryBuilder<T> {
  final _sb = StringBuffer();
  final T _params;

  ParameterizedQueryBuilder._(this._params);

  bool get isEmpty => _sb.isEmpty;

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

  ParameterizedQuery<T> build() {
    return ParameterizedQuery(_sb.toString(), _params);
  }
}

class NamedParameterizedQueryBuilder
    extends ParameterizedQueryBuilder<Map<String, dynamic>> {
  final Dialect _dialect;
  final _counters = <String, int>{};

  NamedParameterizedQueryBuilder(this._dialect) : super._(<String, dynamic>{});

  @override
  void writeParam(dynamic value, {String? key}) {
    final prefix = key ?? 'p';
    var finalKey = prefix;
    while (_params.containsKey(finalKey) && _params[finalKey] != value) {
      final count = (_counters[key] ?? 0) + 1;
      finalKey = '${prefix}_$count';
    }
    _params[finalKey] = value;
    write(_dialect.namedParameter(finalKey));
  }
}
