import 'package:test/test.dart';

import 'package:typed_sql/typed_sql.dart';

void main() {
  group('SELECT', () {
    test('SELECT 1', () {
      final q = SelectQuery([Expr.raw(1)]).render(PostgresDialect());
      expect(q.text, 'SELECT 1');
      expect(q.params, isEmpty);
    });

    test('SELECT * FROM tbl', () {
      final q = SelectQuery(
        [Expr.raw('*')],
        from: [Expr.ref('tbl')],
      ).render(PostgresDialect());
      expect(q.text, 'SELECT * FROM "tbl"');
      expect(q.params, isEmpty);
    });

    test(
        'SELECT lower(a.name) FROM tbl as a WHERE a.status = 1 AND a.name = "Joe"',
        () {
      final q = SelectQuery(
        [Expr.ref('a', 'name').customFn('lower')],
        from: [Expr.ref<Relation>('tbl').as('a')],
        where: Expr.every([
          Expr.ref('a', 'status').eq(1),
          Expr.ref('a', 'name').eq('Joe'),
        ]),
      ).render(PostgresDialect());
      expect(q.text,
          'SELECT lower("a"."name") FROM "tbl" AS "a" WHERE ("a"."status"=@a_status) AND ("a"."name"=@a_name)');
      expect(q.params, {
        'a_status': 1,
        'a_name': 'Joe',
      });
    });

    test('SELECT * FROM tbl ORDER BY updated DESC', () {
      final q = SelectQuery(
        [Expr.raw('*')],
        from: [Expr.ref('tbl')],
        orderBy: [OrderedField(Expr.ref('updated'), order: Order.desc)],
      ).render(PostgresDialect());
      expect(q.text, 'SELECT * FROM "tbl" ORDER BY "updated" DESC');
      expect(q.params, isEmpty);
    });
  });
}
