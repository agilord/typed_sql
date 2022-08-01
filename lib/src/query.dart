import 'expr.dart';
import 'dialect.dart';
import 'renderer.dart';

abstract class QueryVisitor {
  void visitQuery(Query value);
  void visitSelectQuery(SelectQuery value);
  void visitDeleteQuery(DeleteQuery value);
  void visitUpdateQuery(UpdateQuery value);
}

class QueryVisitorBase implements QueryVisitor {
  @override
  void visitQuery(Query value) {
    throw UnimplementedError(
        'Unimplemented in QueryVisitor: ${value.runtimeType}.');
  }

  @override
  void visitSelectQuery(SelectQuery value) => visitQuery(value);

  @override
  void visitDeleteQuery(DeleteQuery value) => visitQuery(value);

  @override
  void visitUpdateQuery(UpdateQuery value) => visitQuery(value);
}

abstract class Query {
  void acceptQueryVisitor(QueryVisitor visitor) => visitor.visitQuery(this);

  ParameterizedQuery<T> render<T>(Dialect<T> dialect) {
    final visitor = RenderQueryVisitor<T>(dialect);
    acceptQueryVisitor(visitor);
    return visitor.render();
  }
}

abstract class DefinitionStatement extends Query {}

abstract class ManipulationStatement extends Query {}

abstract class ResultStatement<R> extends Query {}

abstract class Relation {}

typedef Projection = List<Expr>;
typedef From = List<Expr<Relation>>;
typedef Where = Expr<bool>;
typedef GroupBy = List<Expr>;
typedef OrderBy = List<OrderedField>;
typedef Having = Expr<bool>;
typedef Returning = Projection;

class SelectQuery<R extends Relation> extends ResultStatement<R> {
  final Projection projection;
  final From? from;
  final Where? where;
  final GroupBy? groupBy;
  final OrderBy? orderBy;
  final Having? having;
  final int? offset;
  final int? limit;

  SelectQuery(
    this.projection, {
    this.from,
    this.where,
    this.groupBy,
    this.orderBy,
    this.having,
    this.offset,
    this.limit,
  });

  @override
  void acceptQueryVisitor(QueryVisitor visitor) =>
      visitor.visitSelectQuery(this);
}

class DeleteQuery extends ManipulationStatement {
  final From from;
  final Where? where;
  final int? limit;
  final Returning? returning;

  DeleteQuery({
    required this.from,
    this.where,
    this.limit,
    this.returning,
  });

  @override
  void acceptQueryVisitor(QueryVisitor visitor) =>
      visitor.visitDeleteQuery(this);
}

class UpdateQuery extends ManipulationStatement {
  final RefExpr<Relation> table;
  final List<SetClause>? set;
  final From? from;
  final Where? where;
  final OrderBy? orderBy;
  final int? limit;
  final Returning? returning;

  UpdateQuery({
    required this.table,
    this.set,
    this.from,
    this.where,
    this.orderBy,
    this.limit,
    this.returning,
  });

  @override
  void acceptQueryVisitor(QueryVisitor visitor) =>
      visitor.visitUpdateQuery(this);
}

enum Order {
  asc,
  desc,
}

class OrderedField {
  final Expr expr;
  final Order? order;

  OrderedField(
    this.expr, {
    this.order,
  });
}

class SetClause {
  final String column;
  final Expr expr;

  SetClause(this.column, this.expr);
}
