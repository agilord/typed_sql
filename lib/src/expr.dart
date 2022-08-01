abstract class ExprVisitor {
  void visitExpr(Expr value);
  void visitAliasExpr(AliasExpr value);
  void visitAndExpr(AndExpr value);
  void visitComparisonExpr(ComparisonExpr value);
  void visitCustomFnExpr(CustomFnExpr value);
  void visitIsNullExpr(IsNullExpr value);
  void visitLiteralExpr(LiteralExpr value);
  void visitNotExpr(NotExpr value);
  void visitOrExpr(OrExpr value);
  void visitRawExpr(RawExpr value);
  void visitRefExpr(RefExpr value);
}

class ExprVisitorBase implements ExprVisitor {
  @override
  void visitExpr(Expr value) {
    throw UnimplementedError(
        'Unimplemented in ExprVisitor: ${value.runtimeType}.');
  }

  @override
  void visitAliasExpr(AliasExpr value) => visitExpr(value);

  @override
  void visitAndExpr(AndExpr value) => visitExpr(value);

  @override
  void visitComparisonExpr(ComparisonExpr value) => visitExpr(value);

  @override
  void visitCustomFnExpr(CustomFnExpr value) => visitExpr(value);

  @override
  void visitIsNullExpr(IsNullExpr value) => visitIsNullExpr(value);

  @override
  void visitLiteralExpr(LiteralExpr value) => visitExpr(value);

  @override
  void visitNotExpr(NotExpr value) => visitExpr(value);

  @override
  void visitOrExpr(OrExpr value) => visitExpr(value);

  @override
  void visitRawExpr(RawExpr value) => visitExpr(value);

  @override
  void visitRefExpr(RefExpr value) => visitExpr(value);
}

abstract class Expr<R> {
  static OrExpr any(Iterable<Expr<bool>> items) => OrExpr(items.toList());
  static AndExpr every(Iterable<Expr<bool>> items) => AndExpr(items.toList());
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

  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitExpr(this);

  Expr<C> cast<C>() => this as Expr<C>;
  AliasExpr<R> as(String alias) => AliasExpr<R>(this, alias);

  IsNullExpr isNull() => IsNullExpr(this, true);
  IsNullExpr isNotNull() => IsNullExpr(this, false);

  ComparisonExpr eq(R? v) => eqExpr(_toLiteral(v));
  ComparisonExpr eqExpr(Expr<R> v) => ComparisonExpr(this, '=', v);

  ComparisonExpr neq(R v) => neqExpr(_toLiteral(v));
  ComparisonExpr neqExpr(Expr<R> v) => ComparisonExpr(this, '<>', v);

  ComparisonExpr lt(R v) => ltExpr(_toLiteral(v));
  ComparisonExpr ltExpr(Expr<R> v) => ComparisonExpr(this, '<', v);

  ComparisonExpr lteq(R v) => lteqExpr(_toLiteral(v));
  ComparisonExpr lteqExpr(Expr<R> v) => ComparisonExpr(this, '<=', v);

  ComparisonExpr gt(R v) => gtExpr(_toLiteral(v));
  ComparisonExpr gtExpr(Expr<R> v) => ComparisonExpr(this, '>', v);

  ComparisonExpr gteq(R v) => gteqExpr(_toLiteral(v));
  ComparisonExpr gteqExpr(Expr<R> v) => ComparisonExpr(this, '>=', v);

  CustomFnExpr customFn(String fn, [List<Expr>? args]) =>
      CustomFnExpr(fn, [this, ...?args]);

  Expr<S> _toLiteral<S>(S? v) {
    if (this is RefExpr) {
      final t = this as RefExpr;
      return LiteralExpr<S>(v, key: t.parts.whereType<String>().join('_'));
    }
    return LiteralExpr<S>(v);
  }
}

class AliasExpr<T> extends Expr<T> {
  final Expr<T> inner;
  final String alias;

  AliasExpr(this.inner, this.alias);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitAliasExpr(this);
}

class AndExpr extends BoolExprBase {
  final List<Expr<bool>> items;

  AndExpr(this.items);

  @override
  AndExpr and(Expr<bool> other) => AndExpr([...items, other]);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitAndExpr(this);
}

class ComparisonExpr extends Expr<bool> {
  final Expr left;
  final String operator;
  final Expr right;

  ComparisonExpr(this.left, this.operator, this.right);

  @override
  void acceptExprVisitor(ExprVisitor visitor) =>
      visitor.visitComparisonExpr(this);
}

class CustomFnExpr<T> extends Expr<T> {
  final String fn;
  final List<Expr> params;

  CustomFnExpr(
    this.fn,
    this.params,
  );

  @override
  void acceptExprVisitor(ExprVisitor visitor) =>
      visitor.visitCustomFnExpr(this);
}

class IsNullExpr extends Expr<bool> {
  final Expr expr;
  final bool value;

  IsNullExpr(this.expr, this.value);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitIsNullExpr(this);
}

class LiteralExpr<T> extends Expr<T> {
  final T? value;
  final String? key;

  LiteralExpr(
    this.value, {
    this.key,
  });

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitLiteralExpr(this);
}

class NotExpr extends Expr<bool> {
  final Expr<bool> inner;
  NotExpr(this.inner);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitNotExpr(this);
}

class OrExpr extends BoolExprBase {
  final List<Expr<bool>> items;

  OrExpr(this.items);

  @override
  OrExpr or(Expr<bool> other) => OrExpr([...items, other]);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitOrExpr(this);
}

class RawExpr extends Expr {
  final String text;

  RawExpr(this.text);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitRawExpr(this);
}

class RefExpr<T> extends Expr<T> {
  final List<String> parts;

  RefExpr(this.parts);

  @override
  void acceptExprVisitor(ExprVisitor visitor) => visitor.visitRefExpr(this);
}

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
