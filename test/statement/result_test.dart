import 'package:test/test.dart';

import 'package:typed_sql/typed_sql.dart';

void main() {
  group('SELECT', () {
    test('SELECT 1', () {
      final q = Select(RawExpr('1')).toSql(PostgresDialect());
      expect(q.text, 'SELECT 1');
      expect(q.params, isEmpty);
    });

    test('SELECT * FROM tbl', () {
      final q = Select(
        '*',
        from: 'tbl',
      ).toSql(PostgresDialect());
      expect(q.text, 'SELECT * FROM "tbl"');
      expect(q.params, isEmpty);
    });

    test(
        'SELECT lower(a.name) FROM tbl as a WHERE a.status = 1 AND a.name = "Joe"',
        () {
      final q = Select(
        [Expr.ref('a', 'name').customFn('lower')],
        from: 'tbl AS a',
        where: AndExpr([
          Expr.ref('a', 'status').eq(1),
          Expr.ref('a', 'name').eq('Joe'),
        ]),
      ).toSql(PostgresDialect());
      expect(q.text,
          'SELECT lower("a"."name") FROM "tbl" AS "a" WHERE ("a"."status"=@a_status) AND ("a"."name"=@a_name)');
      expect(q.params, {
        'a_status': 1,
        'a_name': 'Joe',
      });
    });

    test('SELECT id FROM tbl ORDER BY updated DESC', () {
      final q = Select(
        'tbl.entity_id as id',
        from: 'tbl',
        orderBy: [Expr.ref('updated').desc()],
      ).toSql(PostgresDialect());
      expect(q.text,
          'SELECT "tbl"."entity_id" AS "id" FROM "tbl" ORDER BY "updated" DESC');
      expect(q.params, isEmpty);
    });
  });
}
