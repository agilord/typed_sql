part of 'expr.dart';

extension BoolExprExt on Expr<bool> {
  AndExpr and(Expr<bool> other) => AndExpr([this, other]);
  AndExpr operator &(Expr<bool> other) => and(other);
  OrExpr or(Expr<bool> other) => OrExpr([this, other]);
  OrExpr operator |(Expr<bool> other) => or(other);
  NotExpr not() => NotExpr(this);
  NotExpr operator ~() => not();
}

abstract class BoolExprBase extends Expr<bool> {
  AndExpr and(Expr<bool> other) => AndExpr([this, other]);
  AndExpr operator &(Expr<bool> other) => and(other);
  OrExpr or(Expr<bool> other) => OrExpr([this, other]);
  OrExpr operator |(Expr<bool> other) => or(other);
  NotExpr not() => NotExpr(this);
  NotExpr operator ~() => not();
}

class AndExpr extends BoolExprBase {
  final List<Expr<bool>> items;

  AndExpr(Iterable<Expr<bool>> items) : items = items.toList();

  @override
  AndExpr and(Expr<bool> other) => AndExpr([...items, other]);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.writePartsJoined<Expr>(
      items,
      join: ' AND ',
      fn: (p) => p.writeSqlPart(writer),
      partPrefix: '(',
      partPostfix: ')',
    );
  }
}

class OrExpr extends BoolExprBase {
  final List<Expr<bool>> items;

  OrExpr(Iterable<Expr<bool>> items) : items = items.toList();

  @override
  OrExpr or(Expr<bool> other) => OrExpr([...items, other]);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.writePartsJoined<Expr>(
      items,
      join: ' OR ',
      fn: (p) => p.writeSqlPart(writer),
      partPrefix: '(',
      partPostfix: ')',
    );
  }
}

class NotExpr extends Expr<bool> {
  final Expr<bool> inner;
  NotExpr(this.inner);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('NOT(');
    inner.writeSqlPart(writer);
    writer.write(')');
  }
}
