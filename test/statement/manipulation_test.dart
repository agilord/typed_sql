import 'package:test/test.dart';

import 'package:typed_sql/typed_sql.dart';

void main() {
  group('DELETE', () {
    test('DELETE FROM tbl WHERE id = X RETURNING name', () {
      final q = Delete(
        from: 'tbl',
        where: Expr.ref('id').eq('uuid_value'),
        returning: [Expr.ref('name')],
      ).toSql(PostgresDialect());
      expect(q.text, 'DELETE FROM "tbl" WHERE "id"=@id RETURNING "name"');
      expect(q.params, {
        'id': 'uuid_value',
      });
    });
  });

  group('INSERT', () {
    test('single row with columns and values', () {
      final q = Insert(
        table: Expr.ref('tbl'),
        values: Values([
          Expr.literal(1),
          Expr.literal('name'),
        ]),
      ).toSql(PostgresDialect());
      expect(q.text, 'INSERT INTO "tbl" VALUES (@p, @p_1)');
      expect(q.params, {'p': 1, 'p_1': 'name'});
    });

    test('insert with select query', () {
      final q = Insert(
        table: Expr.ref('tbl'),
        values: Select(
          '*',
          from: 'other',
        ),
      ).toSql(PostgresDialect());
      expect(q.text, 'INSERT INTO "tbl" (SELECT * FROM "other")');
      expect(q.params, {});
    });

    test('insert with returning', () {
      final q = Insert(
        table: Expr.ref('tbl'),
        columns: ['id', 'value'],
        values: Values(
          [
            Expr.raw('DEFAULT'),
            Expr.literal('x'),
          ],
        ),
        returning: [Expr.ref('id')],
      ).toSql(PostgresDialect());
      expect(q.text,
          'INSERT INTO "tbl" COLUMNS ("id", "value") VALUES (DEFAULT, @p) RETURNING "id"');
      expect(q.params, {'p': 'x'});
    });
  });

  group('UPDATE', () {
    test('UPDATE users SET address = X WHERE id = Y RETURNING name', () {
      final q = Update(
        table: Expr.ref('users'),
        set: [SetClause('address', Expr.literal('new address'))],
        where: Expr.ref('id').eq('uuid_value'),
        returning: [Expr.ref('name')],
      ).toSql(PostgresDialect());
      expect(q.text,
          'UPDATE "users" SET "address"=@p WHERE "id"=@id RETURNING "name"');
      expect(q.params, {
        'p': 'new address',
        'id': 'uuid_value',
      });
    });
  });
}
