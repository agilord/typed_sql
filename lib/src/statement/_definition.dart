part of 'statement.dart';

class CreateTable extends DefinitionStatement {
  final String name;
  final bool ifNotExists;
  final List<ColumnDef>? columns;
  final PrimaryKey? primaryKey;

  CreateTable(
    this.name, {
    this.ifNotExists = false,
    this.columns,
    Object? primaryKey,
  }) : primaryKey = PrimaryKey._tryParse(primaryKey);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('CREATE TABLE');
    if (ifNotExists) {
      writer.write(' IF NOT EXISTS');
    }
    writer.write(' "$name" (');

    writer.writePartsJoined<SqlPart>(
      [
        ...?columns,
        if (primaryKey != null) primaryKey!,
      ],
      join: ', ',
      fn: (p) => p.writeSqlPart(writer),
    );
    writer.write(')');
  }
}

class CreateIndex extends DefinitionStatement {
  final bool? concurrently;
  final bool? ifNotExists;
  final String? name;
  final String table;
  final String? using;
  final List<OrderedField> columns;

  CreateIndex({
    this.concurrently,
    this.ifNotExists,
    this.name,
    required this.table,
    this.using,
    required Object columns,
  }) : columns = _tryParseOrderBy(columns)!;

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('CREATE INDEX');
    if (concurrently ?? false) {
      writer.write(' CONCURRENTLY');
    }
    if (ifNotExists ?? false) {
      writer.write(' IF NOT EXISTS');
    }
    if (name != null && name!.isNotEmpty) {
      writer.write(' "$name"');
    }
    writer.write(' ON "$table"');
    if (using != null && using!.isNotEmpty) {
      writer.write(' USING $using');
    }
    writer.write(' (');
    writer.writePartsJoined<SqlPart>(
      columns,
      join: ', ',
      fn: (c) => c.writeSqlPart(writer),
    );
    writer.write(')');
  }
}

class ColumnDef extends SqlPart {
  final String name;
  final DataType type;
  final bool? primaryKey;
  final bool? notNull;

  ColumnDef(
    this.name,
    this.type, {
    this.primaryKey,
    this.notNull,
  });

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('"$name" ');
    type.writeSqlPart(writer);
    if (primaryKey ?? false) {
      writer.write(' PRIMARY KEY');
    }
    if (notNull ?? false) {
      writer.write(' NOT NULL');
    }
  }
}

abstract class Constraint extends SqlPart {
  final String? name;

  Constraint({this.name});

  void writeConstraintName(SqlWriter writer) {
    if (name != null) {
      writer.write('CONSTRAINT "$name" ');
    }
  }
}

class PrimaryKey extends Constraint {
  List<OrderedField> columns;

  PrimaryKey(
    this.columns, {
    super.name,
  });

  static PrimaryKey? _tryParse(Object? v) {
    if (v == null) return null;
    if (v is PrimaryKey) return v;
    final list = v is Iterable ? v.toList() : [v];
    return PrimaryKey(_tryParseOrderBy(list)!);
  }

  @override
  void writeSqlPart(SqlWriter writer) {
    writeConstraintName(writer);
    writer.write('PRIMARY KEY (');
    writer.writePartsJoined<SqlPart>(
      columns,
      join: ', ',
      fn: (c) => c.writeSqlPart(writer),
    );
    writer.write(')');
  }
}

class DataType extends SqlPart {
  final String name;
  final List<Object>? params;

  const DataType(
    this.name, {
    this.params,
  });

  factory DataType.bigint() => const DataType('BIGINT');
  factory DataType.binary() => const DataType('BYTEA');
  factory DataType.boolean() => const DataType('BOOLEAN');
  factory DataType.char(int n) => DataType('CHAR', params: [n]);
  factory DataType.double() => const DataType('DOUBLE PRECISION');
  factory DataType.integer() => const DataType('INTEGER');
  factory DataType.jsonb() => const DataType('JSONB');
  factory DataType.smallint() => const DataType('SMALLINT');
  factory DataType.text() => const DataType('TEXT');
  factory DataType.timestamp() => const DataType('TIMESTAMP');
  factory DataType.tsvector() => const DataType('TSVECTOR');
  factory DataType.uuid() => const DataType('UUID');
  factory DataType.varchar(int n) => DataType('VARCHAR', params: [n]);

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write(name);
    if (params != null && params!.isNotEmpty) {
      writer.write('(${params!.join(', ')})');
    }
  }
}

class DropTable extends DefinitionStatement {
  final String name;
  final bool? ifExists;
  final bool? cascade;

  DropTable(
    this.name, {
    this.ifExists,
    this.cascade,
  });

  @override
  void writeSqlPart(SqlWriter writer) {
    writer.write('DROP TABLE');
    if (ifExists ?? false) {
      writer.write(' IF EXISTS');
    }
    writer.write(' "$name"');
    if (cascade ?? false) {
      writer.write(' CASCADE');
    }
  }
}
