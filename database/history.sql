--rename to GetTableColumns
CREATE OR REPLACE FUNCTION _HT_GetTableFields(dbschema text, dbtable text)
	RETURNS text AS
$$
DECLARE
	sql text;
	ret text;

BEGIN
	sql :=
	'SELECT array_to_string(array_agg(column_name::text), '','') FROM 
		(SELECT column_name FROM information_schema.columns
			WHERE table_schema = ''' || quote_ident(dbschema) || '''
			AND table_name = ''' || quote_ident(dbtable) || '''
		ORDER BY ordinal_position) AS foo';

	EXECUTE sql INTO ret;
	
	RETURN ret;
END;
$$
LANGUAGE plpgsql VOLATILE;

--currently returning PK and FK
CREATE OR REPLACE FUNCTION _HT_GetTablePkey(dbschema text, dbtable text)
	RETURNS text AS
$$
DECLARE
	sql text;
	ret text;

BEGIN
	sql := 'SELECT column_name FROM information_schema.key_column_usage
		WHERE table_schema = ''' || quote_ident(dbschema) || '''
		AND table_name = ''' || quote_ident(dbtable) || '''';

	EXECUTE sql INTO ret;

	RETURN ret;
END;
$$
LANGUAGE plpgsql VOLATILE;

--
CREATE OR REPLACE FUNCTION _HT_TableExists(dbschema text, dbtable text)
	RETURNS boolean AS
$$
DECLARE
	sql text;
	cnt integer;

BEGIN
	sql := 'SELECT COUNT(*) FROM information_schema.tables
		WHERE table_schema = ''' || quote_ident(dbschema) || ''' 
		AND table_name = ''' || quote_ident(dbtable) || '''
		AND table_type = ''BASE TABLE''';

/*
--BETTER WRITTEN AS...
select exists (select true 
                 FROM information_schema.tables
                WHERE table_schema = 'public'
                  AND table_name = 'transactions'
                  AND table_type = 'BASE TABLE'
              );
*/    

	EXECUTE sql INTO cnt;

	IF cnt > 0 THEN
		RETURN True;
	ELSE
		RETURN False;
	END IF;
END;
$$
LANGUAGE plpgsql VOLATILE;

-- udt_name doesn't give full value of type like numeric(28,2)
CREATE OR REPLACE FUNCTION _HT_CreateDiffType(dbschema text, dbtable text)
RETURNS boolean AS
$$
DECLARE
	sql_get_fields text;
	rec RECORD;
	
	fields text;
	sql_create_type text;

BEGIN

	sql_get_fields := 'SELECT column_name, udt_name FROM information_schema.columns
		WHERE table_schema = ''' || quote_ident(dbschema) || ''' 
		AND table_name = ''' || quote_ident(dbtable) || '''
		ORDER BY ordinal_position';

	fields := 'operation character(1)';
	FOR rec IN EXECUTE(sql_get_fields) LOOP
		fields := fields || ', ' || rec.column_name || ' ' || rec.udt_name;
	END LOOP;

	sql_create_type := 
		'CREATE TYPE ' || quote_ident(dbschema) || '.' || 'ht_' || quote_ident(dbtable) || '_difftype AS (' ||
		fields || ')';
	EXECUTE sql_create_type;

	RETURN True;
END;
$$
LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION _HT_CreateAutitTable(dbschema text, dbtable text)
RETURNS boolean AS
$$
DECLARE
	sql_get_fields text;
	rec RECORD;
	fields text;
	sql_create_type text;

BEGIN
	
END;
$$
LANGUAGE plpgsql VOLATILE;