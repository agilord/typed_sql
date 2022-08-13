part of 'statement.dart';

enum Order {
  asc,
  desc,
}

class OrderedField extends SqlPart {
  final Expr expr;
  final Order? order;

  OrderedField(this.expr, [this.order]);

  @override
  void writeSqlPart(SqlWriter writer) {
    expr.writeSqlPart(writer);
    writer._writeOrder(order);
  }
}

extension OrderedFieldExprExt<T> on RefExpr<T> {
  OrderedField asc() => OrderedField(this, Order.asc);
  OrderedField desc() => OrderedField(this, Order.desc);
}

typedef Projection = List<Expr>;
typedef From = List<Expr<Relation>>;
typedef Where = Expr<bool>;
typedef GroupBy = List<Expr>;
typedef OrderBy = List<OrderedField>;
typedef Having = Expr<bool>;
typedef Returning = Projection;

Projection _parseProjection(Object v) {
  final list = v is Iterable ? v.toList() : [v];
  return list.map((e) {
    if (e is Expr) return e;
    if (e is String) {
      if (e == '*') {
        return RawExpr(e);
      }
      return _parseRefExprWithAlias(e);
    }
    throw ArgumentError('Unable to parse ${e.runtimeType} as Projection: $e');
  }).toList();
}

final _asRegExp = RegExp(' as ', caseSensitive: false);
From _parseFrom(Object v) {
  final list = v is Iterable ? v.toList() : [v];
  return list.map((e) {
    if (e is Expr<Relation>) return e;
    if (e is String) {
      return _parseRefExprWithAlias<Relation>(e);
    }
    throw ArgumentError('Unable to parse ${e.runtimeType} as From: $e');
  }).toList();
}

Expr<T> _parseRefExprWithAlias<T>(String e) {
  final asParts = e.split(_asRegExp);
  final refExpr = RefExpr<T>(asParts.first.trim().split('.'));
  if (refExpr.parts.isEmpty) {
    throw ArgumentError('Unable to parse reference: $e as From part.');
  }
  if (asParts.length == 2) {
    final alias = asParts[1].trim();
    if (alias.isEmpty) {
      throw ArgumentError('Unable to parse reference: $e as From part.');
    }
    return refExpr.aliasAs(alias);
  }
  return refExpr;
}

OrderBy? _tryParseOrderBy(Object? v) {
  if (v == null) return null;
  final list = v is Iterable ? v.toList() : [v];
  return list.map((e) {
    if (e is OrderedField) return e;
    if (e is RefExpr) return OrderedField(e);
    if (e is String) return OrderedField(_parseRefExprWithAlias(e));
    throw ArgumentError('Unable to parse reference: $e as OrderBy part.');
  }).toList();
}

From? _tryParseFrom(Object? v) {
  if (v == null) return null;
  return _parseFrom(v);
}

extension on SqlWriter {
  void _writeFrom(From? value) {
    if (value != null && value.isNotEmpty) {
      write(' FROM ');
      writePartsJoined<Expr>(
        value,
        join: ', ',
        fn: (p) => p.writeSqlPart(this),
      );
    }
  }

  void _writeWhere(Where? part) {
    if (part != null) {
      write(' WHERE ');
      part.writeSqlPart(this);
    }
  }

  void _writeOrderBy(OrderBy? value) {
    if (value != null && value.isNotEmpty) {
      write(' ORDER BY ');
      writePartsJoined<SqlPart>(
        value,
        join: ', ',
        fn: (p) => p.writeSqlPart(this),
      );
    }
  }

  void _writeOrder(Order? order) {
    if (order == null) return;
    switch (order) {
      case Order.asc:
        write(' ASC');
        break;
      case Order.desc:
        write(' DESC');
        break;
    }
  }

  void _writeOffset(int? value) {
    if (value != null) {
      write(' OFFSET $value');
    }
  }

  void _writeLimit(int? value) {
    if (value != null) {
      write(' LIMIT $value');
    }
  }

  void _writeReturning(Returning? value) {
    if (value != null) {
      write(' RETURNING ');
      writePartsJoined<Expr>(
        value,
        join: ', ',
        fn: (p) => p.writeSqlPart(this),
      );
    }
  }
}
