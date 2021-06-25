DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE OR REPLACE FUNCTION transpose(A float[][]) RETURNS float[][] AS $$
<< outerblock >>
DECLARE
    B float[][] := '{}';
    linha float[] := '{}';
BEGIN

    FOR c IN 1..array_length(A,2) LOOP
        linha := '{}';
        FOR r IN 1..array_length(A,1) LOOP
            linha := array_append(linha, A[r][c]);
        END LOOP;
        B := array_cat(B, array[linha]);
    END LOOP;


    RETURN B;
END;
$$ LANGUAGE plpgsql;

do $$
declare
    A float[][];
    B float[][];
begin
    A := '{
        {1,2}, 
        {3,4},
        {5,6}
    }';

    B := transpose(A);
    RAISE NOTICE '%', B;

    A := '{
        {1,2,3}, 
        {4,5,6},
        {7,8,9}
    }';

    B := transpose(A);
    RAISE NOTICE '%', B;
    
    A := '{
        {1}, 
        {2},
        {7}
    }';

    B := transpose(A);
    RAISE NOTICE '%', B;
end;$$