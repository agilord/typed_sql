import 'expr.dart';
import 'query.dart';

class Schema {
  final List<Table> tables;

  Schema({
    required this.tables,
  });
}

class Table {
  final String? schema;
  final String name;
  final List<Column> columns;
  final List<PrimaryKey> primaryKey;
  final List<Index>? indexes;

  Table(
    this.name, {
    this.schema,
    required this.columns,
    required this.primaryKey,
    this.indexes,
  });

  late final ref =
      RefExpr<Relation>([schema, name].whereType<String>().toList());
}

class Column<T> {
  final String? schema;
  final String? table;
  final String name;
  final String type;
  final String? family;
  final bool? isNullable;
  final bool? isUnique;

  Column(
    this.name, {
    this.schema,
    this.table,
    required this.type,
    this.family,
    this.isNullable,
    this.isUnique,
  });

  late final ref =
      RefExpr<T>([schema, table, name].whereType<String>().toList());
}

enum IndexType {
  btree,
  gin,
  hash,
}

class Index {
  final String name;
  final IndexType? type;
  final List<IndexColumn> columns;
  final List<String>? storing;

  Index(
    this.name, {
    this.type,
    required this.columns,
    this.storing,
  });
}

class PrimaryKey {
  final String column;
  final Order? order;

  PrimaryKey(
    this.column, {
    this.order,
  });
}

class IndexColumn {
  final Expr expr;
  final Order? order;

  IndexColumn(
    this.expr, {
    this.order,
  });
}
