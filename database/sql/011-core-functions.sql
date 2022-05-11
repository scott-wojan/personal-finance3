/************************************************************************************************************
core functions
************************************************************************************************************/

create or replace function months_between (startDate timestamp, endDate timestamp)
returns integer as $$
select ((extract('years' from $2)::int -  extract('years' from $1)::int) * 12) 
    - extract('month' from $1)::int + extract('month' from $2)::int
$$ 
LANGUAGE SQL
immutable 
returns NULL on NULL input;

create or replace function end_of_month(date)
returns date as $$
select (date_trunc('month', $1) + interval '1 month' - interval '1 day')::date;
$$ 
language SQL
immutable strict;


create or replace function set_updated_at_trigger()
returns trigger as $$
begin
  NEW.updated_at = NOW();
  return NEW;
end;
$$ language plpgsql;


create or replace function create_updated_at_trigger_for_table(tablename text) 
  returns void
  language plpgsql
 as $$
  declare
  begin

    execute 'drop trigger if exists update_created_at_trigger on '||tablename;
    execute 'create trigger update_created_at_trigger BEFORE UPDATE on '||tablename||' FOR EACH ROW execute procedure set_updated_at_trigger()';
    
  end
$$;



create or replace function ensure_updated_at_triggers_exist(database text, schema text)
  returns void
  language plpgsql
 as $$
  declare
   results record;
  begin

    FOR results IN select tables.table_name
      from information_schema.tables tables
          inner join information_schema.columns columns on columns.table_name = tables.table_name and columns.column_name = 'updated_at'
    where tables.table_catalog = database
      and tables.table_schema = schema 
      and tables.table_type = 'BASE TABLE'
      and tables.is_insertable_into = 'YES'
      and not exists (
          select 1 
            from information_schema.triggers triggers
            where triggers.trigger_name = 'update_created_at_trigger'
              and triggers.event_object_catalog = tables.table_catalog
              and triggers.event_object_schema = tables.table_schema
              and triggers.event_object_table = tables.table_name
      )
    LOOP
        PERFORM create_updated_at_trigger_for_table(results.table_name);
    END LOOP;

  end
$$;


-- do $$
-- begin
--   execute ensure_updated_at_triggers_exist('financials','public');
-- end;
-- $$