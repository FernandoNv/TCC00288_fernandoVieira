DO $$
DECLARE
    _sql text;
BEGIN
    SELECT
    INTO _sql
          string_agg(format('DROP %s IF EXISTS %s CASCADE;'
                          , CASE prokind
                              WHEN 'f' THEN 'FUNCTION'
                              WHEN 'a' THEN 'AGGREGATE'
                              WHEN 'p' THEN 'PROCEDURE'
                              WHEN 'w' THEN 'FUNCTION'
                            END
                          , oid::regprocedure)
                   , E'\n')
    FROM   pg_proc
    WHERE  pronamespace = 'public'::regnamespace;

    IF _sql IS NOT NULL THEN
        RAISE NOTICE E'\n\n%', _sql;
        EXECUTE _sql;
    END IF;
END$$;



CREATE OR REPLACE FUNCTION drop_functions() RETURNS void as $do$
DECLARE
   _sql text;
BEGIN
    SELECT
    INTO _sql
        string_agg(format('DROP %s IF EXISTS %s CASCADE;'
                    , CASE prokind
                        WHEN 'f' THEN 'FUNCTION'
                        WHEN 'a' THEN 'AGGREGATE'
                        WHEN 'p' THEN 'PROCEDURE'
                        WHEN 'w' THEN 'FUNCTION'
                        -- ELSE NULL
                      END
                    , oid::regprocedure)
            , E'\n')
    FROM   pg_proc
    WHERE  pronamespace = 'public'::regnamespace
    AND not array[proname] <@ '{"drop_functions","drop_tables"}';

    IF _sql IS NOT NULL THEN
        RAISE NOTICE E'\n\n%', _sql;
        EXECUTE _sql;
    END IF;
END$do$ language plpgsql;





CREATE OR REPLACE FUNCTION drop_tables() RETURNS void as $do$
DECLARE
    _sql text;
BEGIN
    SELECT
    INTO _sql
        string_agg(format('DROP TABLE IF EXISTS %s CASCADE;', c.oid::regclass), E'\n')
    FROM pg_catalog.pg_class c
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('r','s') AND  (n.nspname = 'public' OR (n.nspname !~ '^pg_toast' AND nspname LIKE 'pg_temp%'));

    IF _sql IS NOT NULL THEN
        RAISE NOTICE E'\n\n%', _sql;
        EXECUTE _sql;
    END IF;



    SELECT
    INTO _sql
        string_agg(format('DROP TYPE IF EXISTS %s CASCADE;', c.oid::regclass), E'\n')
    FROM pg_catalog.pg_class c
    LEFT JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace
    WHERE c.relkind IN ('c') AND  (n.nspname = 'public' OR (n.nspname !~ '^pg_toast' AND nspname LIKE 'pg_temp%'));

    IF _sql IS NOT NULL THEN
        RAISE NOTICE E'\n\n%', _sql;
        EXECUTE _sql;
    END IF;
END$do$ language plpgsql;


DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;


