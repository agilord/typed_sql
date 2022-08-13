import '../dialect.dart';

part '_bool.dart';
part '_comparison.dart';

abstract class Expr<R> extends SqlPart {
  static LiteralExpr<T> literal<T>(T? value, {String? key}) {
    return LiteralExpr(value, key: key);
  }

  static RawExpr raw(Object text) => RawExpr(text.toString());

  static RefExpr<T> ref<T>(Object p1,
      [Object? p2, Object? p3, Object? p4, Object? p5]) {
    final list = [p1, p2, p3, p4, p5].whereType<Object>().toList();
    if (list.every((e) => e is String)) {
      return RefExpr(list.cast<String>());
    }
    throw ArgumentError(
        'Unable to parse ref type(s): `${list.map((e) => e.runtimeType).join(', ')}`.');
  }

  Expr<C> cast<C>() => this as Expr<C>;
  AliasExpr<R> aliasAs(String alias) => AliasExpr<R>(this, alias);

  CustomFnExpr customFn(String fn, [List<Expr>? args]) =>
      CustomFnExpr(fn, [this, ...?args]);
}

class AliasExpr<T> extends Expr<T> {
  final Expr<T> inner;
  final String alias;

  AliasExpr(this.inner, this.alias);

  @override
  void writeSqlPart(SqlWriter writer) {
    inner.writeSqlPart(writer);
    writer.write(' AS "$alias"');
  }
}

class CustomFnExpr<T> extends Expr<T> {
  final String fn;
  final List<Expr> params;

  CustomFnExpr(
    this.fn,
    this.params,
  );

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('$fn(');
    writer.writePartsJoined<Expr>(
      params,
      join: ', ',
      fn: (p) => p.writeSqlPart(writer),
    );
    writer.write(')');
  }
}

class LiteralExpr<T> extends Expr<T> {
  final T? value;
  final String? key;

  LiteralExpr(
    this.value, {
    this.key,
  });

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.writeParam(value, key: key);
  }
}

class RawExpr extends Expr {
  final String text;

  RawExpr(this.text);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write(text);
  }
}

class RefExpr<T> extends Expr<T> {
  final List<String> parts;

  RefExpr(this.parts);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write(parts.map((e) => '"$e"').join('.'));
  }
}
