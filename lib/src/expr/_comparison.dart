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
  ComparisonExpr eq(v) => ComparisonExpr(this, '=', _toExpr(v));
  ComparisonExpr neq(v) => ComparisonExpr(this, '<>', _toExpr(v));
  ComparisonExpr lt(v) => ComparisonExpr(this, '<', _toExpr(v));
  ComparisonExpr lteq(R v) => ComparisonExpr(this, '<=', _toExpr(v));
  ComparisonExpr gt(R v) => ComparisonExpr(this, '>', _toExpr(v));
  ComparisonExpr gteq(R v) => ComparisonExpr(this, '>=', _toExpr(v));

  Expr<S> _toExpr<S>(S? v) {
    if (this is RefExpr) {
      final t = this as RefExpr;
      return LiteralExpr<S>(v, key: t.parts.whereType<String>().join('_'));
    }
    return LiteralExpr<S>(v);
  }
}
