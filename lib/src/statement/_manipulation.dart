part of 'statement.dart';

class Delete extends ManipulationStatement {
  final From from;
  final Where? where;
  final int? limit;
  final Returning? returning;

  Delete({
    required Object from,
    this.where,
    this.limit,
    this.returning,
  }) : from = _parseFrom(from);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('DELETE');
    writer._writeFrom(from);
    writer._writeWhere(where);
    writer._writeLimit(limit);
    writer._writeReturning(returning);
  }
}

class Insert extends ManipulationStatement {
  final RefExpr<Relation> table;
  final List<String>? columns;
  final ResultStatement<Relation> values;
  final Returning? returning;

  Insert({
    required this.table,
    this.columns,
    required this.values,
    this.returning,
  });

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('INSERT INTO ');
    table.writeSqlPart(writer);
    if (columns != null && columns!.isNotEmpty) {
      writer.write(' COLUMNS (');
      writer.write(columns!.map((e) => '"$e"').join(', '));
      writer.write(')');
    }
    writer.write(' ');
    values.writeSqlPart(writer);
    writer._writeReturning(returning);
  }
}

class Update extends ManipulationStatement {
  final RefExpr<Relation> table;
  final List<SetClause>? set;
  final From? from;
  final Where? where;
  final OrderBy? orderBy;
  final int? limit;
  final Returning? returning;

  Update({
    required this.table,
    this.set,
    this.from,
    this.where,
    this.orderBy,
    this.limit,
    this.returning,
  });

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('UPDATE ');
    table.writeSqlPart(writer);
    if (set != null && set!.isNotEmpty) {
      writer.write(' SET ');
      writer.writePartsJoined<SetClause>(
        set!,
        join: ', ',
        fn: (p) {
          writer.write('"${p.column}"=');
          p.expr.writeSqlPart(writer);
        },
      );
    }
    writer._writeFrom(from);
    writer._writeWhere(where);
    writer._writeOrderBy(orderBy);
    writer._writeLimit(limit);
    writer._writeReturning(returning);
  }
}

class SetClause {
  final String column;
  final Expr expr;

  SetClause(this.column, this.expr);
}
