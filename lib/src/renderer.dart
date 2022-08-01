import 'dialect.dart';
import 'expr.dart';
import 'query.dart';

class RenderQueryVisitor<T> extends Object
    with QueryVisitorBase, ExprVisitorBase {
  final ParameterizedQueryBuilder<T> _builder;
  bool _done = false;

  RenderQueryVisitor(Dialect<T> dialect) : _builder = dialect.newQueryBuilder();

  @override
  void visitSelectQuery(SelectQuery<Relation> value) {
    final isSubQuery = !_builder.isEmpty;
    if (isSubQuery) _builder.write('(');
    _builder.write('SELECT ');
    _builder.writePartsJoined<Expr>(
      value.projection,
      join: ', ',
      fn: (p) => p.acceptExprVisitor(this),
    );
    _writeFrom(value.from);
    _writeWhere(value.where);
    final groupBy = value.groupBy;
    if (groupBy != null && groupBy.isNotEmpty) {
      _builder.write(' GROUP BY ');
      _builder.writePartsJoined<Expr>(
        groupBy,
        join: ', ',
        fn: (p) => p.acceptExprVisitor(this),
      );
    }
    _writeOrderBy(value.orderBy);
    final having = value.having;
    if (having != null) {
      _builder.write(' HAVING ');
      having.acceptExprVisitor(this);
    }
    _writeOffset(value.offset);
    _writeLimit(value.limit);
    if (isSubQuery) _builder.write(')');
  }

  void _writeFrom(From? value) {
    if (value != null && value.isNotEmpty) {
      _builder.write(' FROM ');
      _builder.writePartsJoined<Expr>(
        value,
        join: ', ',
        fn: (p) => p.acceptExprVisitor(this),
      );
    }
  }

  void _writeWhere(Where? part) {
    if (part != null) {
      _builder.write(' WHERE ');
      part.acceptExprVisitor(this);
    }
  }

  void _writeOrderBy(OrderBy? value) {
    if (value != null && value.isNotEmpty) {
      _builder.write(' ORDER BY ');
      _builder.writePartsJoined<OrderedField>(
        value,
        join: ', ',
        fn: (p) {
          p.expr.acceptExprVisitor(this);
          _writeOrder(p.order);
        },
      );
    }
  }

  void _writeOrder(Order? order) {
    if (order == null) return;
    switch (order) {
      case Order.asc:
        _builder.write(' ASC');
        break;
      case Order.desc:
        _builder.write(' DESC');
        break;
    }
  }

  void _writeOffset(int? value) {
    if (value != null) {
      _builder.write(' OFFSET $value');
    }
  }

  void _writeLimit(int? value) {
    if (value != null) {
      _builder.write(' LIMIT $value');
    }
  }

  @override
  void visitDeleteQuery(DeleteQuery value) {
    _builder.write('DELETE ');
    _writeFrom(value.from);
    _writeWhere(value.where);
    _writeLimit(value.limit);
    _writeReturning(value.returning);
  }

  @override
  void visitUpdateQuery(UpdateQuery value) {
    _builder.write('UPDATE ');
    value.table.acceptExprVisitor(this);
    final set = value.set;
    if (set != null && set.isNotEmpty) {
      _builder.write(' SET ');
      _builder.writePartsJoined<SetClause>(
        set,
        join: ', ',
        fn: (p) {
          _builder.write("${p.column}=");
          p.expr.acceptExprVisitor(this);
        },
      );
    }
    _writeFrom(value.from);
    _writeWhere(value.where);
    _writeOrderBy(value.orderBy);
    _writeLimit(value.limit);
    _writeReturning(value.returning);
  }

  void _writeReturning(Returning? value) {
    if (value != null) {
      _builder.write(' RETURNING ');
      _builder.writePartsJoined<Expr>(
        value,
        join: ', ',
        fn: (p) => p.acceptExprVisitor(this),
      );
    }
  }

  @override
  void visitAliasExpr(AliasExpr value) {
    value.inner.acceptExprVisitor(this);
    _builder.write(' AS "${value.alias}"');
  }

  @override
  void visitAndExpr(AndExpr value) {
    _builder.writePartsJoined<Expr>(
      value.items,
      join: ' AND ',
      fn: (p) => p.acceptExprVisitor(this),
      partPrefix: '(',
      partPostfix: ')',
    );
  }

  @override
  void visitComparisonExpr(ComparisonExpr value) {
    value.left.acceptExprVisitor(this);
    _builder.write(value.operator);
    value.right.acceptExprVisitor(this);
  }

  @override
  void visitCustomFnExpr(CustomFnExpr value) {
    _builder.write('${value.fn}(');
    _builder.writePartsJoined<Expr>(
      value.params,
      join: ', ',
      fn: (p) => p.acceptExprVisitor(this),
    );
    _builder.write(')');
  }

  @override
  void visitIsNullExpr(IsNullExpr value) {
    value.expr.acceptExprVisitor(this);
    _builder.write(value.value ? ' IS NULL' : 'IS NOT NULL');
  }

  @override
  void visitLiteralExpr(LiteralExpr value) {
    _builder.writeParam(value.value, key: value.key);
  }

  @override
  void visitNotExpr(NotExpr value) {
    _builder.write('NOT(');
    value.inner.acceptExprVisitor(this);
    _builder.write(')');
  }

  @override
  void visitOrExpr(OrExpr value) {
    _builder.writePartsJoined<Expr>(
      value.items,
      join: ' OR ',
      fn: (p) => p.acceptExprVisitor(this),
      partPrefix: '(',
      partPostfix: ')',
    );
  }

  @override
  void visitRawExpr(RawExpr value) {
    _builder.write(value.text);
  }

  @override
  void visitRefExpr(RefExpr value) {
    _builder.write(value.parts.map((e) => '"$e"').join('.'));
  }

  ParameterizedQuery<T> render() {
    if (_done) {
      throw StateError('render can be called only once');
    }
    _done = true;
    return _builder.build();
  }
}
