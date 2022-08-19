part of 'expr.dart';

class IsNullExpr extends Expr<bool> {
  final Expr expr;
  final bool value;

  IsNullExpr(this.expr, this.value);

  @override
  void writeSqlPart(SqlWriter writer) {
    expr.writeSqlPart(writer);
    writer.write(value ? ' IS NULL' : 'IS NOT NULL');
  }
}

extension IsNullExt on Expr {
  IsNullExpr isNull() => IsNullExpr(this, true);
  IsNullExpr isNotNull() => IsNullExpr(this, false);
}

class ComparisonExpr<T> extends Expr<bool> {
  final Expr<T> left;
  final String operator;
  final Expr<T> right;

  ComparisonExpr(this.left, this.operator, this.right);

  @override
  void writeSqlPart(SqlWriter writer) {
    left.writeSqlPart(writer);
    writer.write(operator);
    right.writeSqlPart(writer);
  }
}

extension ComparisonExprExt<R> on Expr<R> {
  ComparisonExpr<R> eq(/** R | Expr<R> */ v) =>
      ComparisonExpr<R>(this, '=', _toExpr(v));
  ComparisonExpr<R> neq(/** R | Expr<R> */ v) =>
      ComparisonExpr<R>(this, '<>', _toExpr(v));
  ComparisonExpr<R> lt(/** R | Expr<R> */ v) =>
      ComparisonExpr<R>(this, '<', _toExpr(v));
  ComparisonExpr<R> lteq(/** R | Expr<R> */ v) =>
      ComparisonExpr<R>(this, '<=', _toExpr(v));
  ComparisonExpr<R> gt(/** R | Expr<R> */ v) =>
      ComparisonExpr<R>(this, '>', _toExpr(v));
  ComparisonExpr<R> gteq(/** R | Expr<R> */ v) =>
      ComparisonExpr<R>(this, '>=', _toExpr(v));

  Expr<R> _toExpr(dynamic v) {
    if (v is Expr<R>) {
      return v;
    }
    if (v is R?) {
      if (this is RefExpr) {
        final t = this as RefExpr;
        return LiteralExpr<R>(v, key: t.parts.whereType<String>().join('_'));
      } else {
        return LiteralExpr<R>(v);
      }
    }
    throw ArgumentError('Unknown type `${v.runtimeType}` of `$v`.');
  }
}
