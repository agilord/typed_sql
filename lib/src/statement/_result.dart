part of 'statement.dart';

class Select<R extends Relation> extends ResultStatement<R> {
  final Projection projection;
  final From? from;
  final Where? where;
  final GroupBy? groupBy;
  final OrderBy? orderBy;
  final Having? having;
  final int? offset;
  final int? limit;

  Select(
    Object projection, {
    Object? from,
    this.where,
    this.groupBy,
    Object? orderBy,
    this.having,
    this.offset,
    this.limit,
  })  : projection = _parseProjection(projection),
        from = _tryParseFrom(from),
        orderBy = _tryParseOrderBy(orderBy);

  @override
  void writeSqlPart(SqlWriter writer) {
    final isSubQuery = writer.isNotEmpty;
    if (isSubQuery) writer.write('(');
    writer.write('SELECT ');
    writer.writePartsJoined<Expr>(
      projection,
      join: ', ',
      fn: (p) => p.writeSqlPart(writer),
    );
    writer._writeFrom(from);
    writer._writeWhere(where);
    if (groupBy != null && groupBy!.isNotEmpty) {
      writer.write(' GROUP BY ');
      writer.writePartsJoined<Expr>(
        groupBy!,
        join: ', ',
        fn: (p) => p.writeSqlPart(writer),
      );
    }
    writer._writeOrderBy(orderBy);
    if (having != null) {
      writer.write(' HAVING ');
      having!.writeSqlPart(writer);
    }
    writer._writeOffset(offset);
    writer._writeLimit(limit);
    if (isSubQuery) writer.write(')');
  }
}

class Values<R extends Relation> extends ResultStatement<R> {
  final List<List<Expr>> rows;

  Values(List<Expr> row) : rows = [row];
  Values.rows(this.rows);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('VALUES ');
    writer.writePartsJoined<List<Expr>>(
      rows,
      join: ', ',
      fn: (p) {
        writer.write('(');
        writer.writePartsJoined<Expr>(
          p,
          join: ', ',
          fn: (v) => v.writeSqlPart(writer),
        );
        writer.write(')');
      },
    );
  }
}
