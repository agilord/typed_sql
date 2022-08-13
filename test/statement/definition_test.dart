import 'package:test/test.dart';

import 'package:typed_sql/typed_sql.dart';

void main() {
  group('CREATE TABLE', () {
    test('simple PK', () {
      final q = CreateTable(
        'tbl',
        columns: [
          ColumnDef('id', DataType.uuid(), primaryKey: true),
        ],
      ).toSql(PostgresDialect());
      expect(q.text, 'CREATE TABLE "tbl" ("id" UUID PRIMARY KEY)');
      expect(q.params, isEmpty);
    });

    test('complex PK', () {
      final q = CreateTable(
        'tbl',
        columns: [
          ColumnDef('x_id', DataType.integer()),
          ColumnDef('y_id', DataType.integer()),
          ColumnDef('text', DataType.text()),
        ],
        primaryKey: ['x_id DESC', 'y_id'],
      ).toSql(PostgresDialect());
      expect(q.text,
          'CREATE TABLE "tbl" ("x_id" INTEGER, "y_id" INTEGER, "text" TEXT, PRIMARY KEY ("x_id DESC", "y_id"))');
      expect(q.params, isEmpty);
    });
  });
}
