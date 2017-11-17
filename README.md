DDL extractor functions  for PostgreSQL
=======================================

This is an SQL-only extension for PostgreSQL that provides uniform functions for generating 
SQL DDL scripts for objects stored in a database. It contains a lot of foo to convert
Postgres system catalogs to nicely formatted SQL snippets. 

Some other SQL databases support commands like SHOW CREATE TABLE or provide 
other fascilities for the purpose. 

PostgreSQL currently doesn't provide overall in-server DDL extracting functions,
but rather just a separate `pg_dump` program. It is an external tool to the server 
and therefore requires shell access or local installation to be of use.

PostgreSQL however already provides a number of helper functions which greatly help with
reconstructing DDL and are of course used by this extension.
It also has sophisticated query capabilities which make this project possible.

Advantages over using other tools like `psql` or `pgdump` include:

- You can use it extract DDL with any client which support running plain SQL queries
- With SQL you can select things to dump by using usual SQL semantics (WHERE, etc)
- Created scripts are somewhat more intended to be run and copy/pasted manually by the DBA
  into other databases/scripts. This means prefering ALTER to CREATE, creating indexes which
  are part of a constraint with ADD CONSTRAINT and such.
- No shell access or shell commands with hairy options required (for running pg_dump), just use SELECT nd hairy SQL!
- It is entrely made out of plain SQL functions.

Some disadvantages:

- Not all Postgres objects are supported. It provides support for the basic user-level objects.
- It is not well tested at all. While it contains a number of regression tests, these can be
  hardly considered as proofs of correctness. Be certain there are bugs. Use at your own risk!
- It is kind of slow-ish for complicated stuff

It is currently incomplete, but still useful. 

Curently tested on PostgreSQL 9.6. Might work with other versions.

Plans on how to make this support newer fetures AND older servers are being considered.
 

Installation
------------

To build and install this module:

    make
    make install
    make install installcheck

or selecting a specific PostgreSQL installation:

    make PG_CONFIG=/some/where/bin/pg_config
    make PG_CONFIG=/some/where/bin/pg_config install

And finally inside the database:

    CREATE EXTENSION ddl;

It you use multiple schemas, you will need to have variable `search_path` 
set appropriately for the extension to work. To make it work with any value of
`search_path`, you can install the extension in the `pg_catalog` schema:

    CREATE EXTENSION ddl SCHEMA pg_catalog;

This of course requires superuser privileges.

Using
-----

This module provides three main end user functions:

- `pg_ddlx_create(oid)` - builds create statements
- `pg_ddlx_drop(oid)` - builds drop statements
- `pg_ddlx_script(oid)` - builds entrie scripts

Currently supported object types are `regclass`,`regtype`,`regproc`,`regprocedure`,
`regoper`,`regoperator` and `regrole`. 
You will probably want to cast object name or oid to the appropriate type.

- `pg_ddlx_create(regclass) returns text`

    Extracts SQL DDL source of a class (table or view) `regclass`.
    This also includes all associated comments, ownership, constraints, 
    indexes, triggers, rules, grants, etc...

- `pg_ddlx_create(regproc) returns text`
- `pg_ddlx_create(regprocedure) returns text`

    Extracts SQL DDL source of function `regproc`.

- `pg_ddlx_create(regtype) returns text`

    Extracts SQL DDL source for type `regtype`.

- `pg_ddlx_create(regrole) returns text`

    Extracts SQL DDL definition for role (user or group) `regrole`.
    
- `pg_ddlx_create(regoper) returns text`
- `pg_ddlx_create(regoperator) returns text`

    Extracts SQL DDL source of operator `regpoper`.

There is also a convenience function to use `oid` directly, without casting:

- `pg_ddlx_create(oid) returns text`

    Extracts SQL DDL source for object ID, `oid`..

- `pg_ddlx_drop(oid) returns text`

    Generates SQL DDL DROP statement for object ID, `oid`..

There is also a higher level function to build entire scripts. Scripts include dependant objects.
At the begining of a script, there are commented DROP statements for all dependant objects, so you can see them easily.
At the end of a script, there are CREATE statements to rebuild the dependant objects.

- `pg_ddlx_script(oid) returns text`

    Generates SQL DDL script for object ID, `oid`..

- `pg_ddlx_script(text) returns text`

    Generates SQL DDL script for sql identifier`.

For example:

```sql
CREATE TABLE users (
    id int PRIMARY KEY,
    name text
);

SELECT pg_ddlx_script('users'::regclass);

CREATE TYPE my_enum AS ENUM ('foo','bar');

SELECT pg_ddlx_script('my_enum'::regtype);

SELECT pg_ddlx_script(current_role::regrole);

```

A number of other functions are provided to extract more specific objects.
Their names all begin with `pg_ddlx_`. They are used internally by the extension 
and are possibly subject to change in future versions of the extension. 
They are generally not intended to be used by the end user. 
Nevertheless, some of them are:

- `pg_ddlx_identify(oid) returns table(oid oid, classid regclass, name name, namespace name, kind text, owner name, sql_kind text, sql_identifier text)`

    Identify an object by object ID, `oid`. This function is used a lot in others.

- `pg_ddlx_create_table(regclass) returns text`

    Extracts SQL DDL source of a table.

- `pg_ddlx_create_view(regclass) returns text`

    Extracts SQL DDL source of a view.

- `pg_ddlx_create_class(regclass) returns text`

    Extracts SQL DDL source of a table or a view.

- `pg_ddlx_create_function(regprocedure) returns text`

    Extracts SQL DDL source of a function.

See files `ddl.sql` and `test/expected/init.out` for details.
