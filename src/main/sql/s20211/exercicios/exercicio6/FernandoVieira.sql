DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE OR REPLACE FUNCTION combinacaoLinear(A float[][], m INTEGER, n INTEGER, c1 FLOAT, c2 FLOAT) RETURNS float[][] AS $$
<< outerblock >>
DECLARE
    B float[][] := '{}';
    linha float[] := '{}';
BEGIN

    FOR i IN 1..array_length(A,1) LOOP
        linha := '{}';
        FOR j IN 1..array_length(A,2) LOOP
            IF i = m THEN
                linha := array_append(linha, c1*A[m][j] + c2*A[n][j]);
            ELSE
                linha := array_append(linha, A[i][j]);
            END IF;
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
        {1,2,3}, 
        {4,5,6},
        {7,8,9}
    }';

    B := combinacaoLinear(A,1,3,5,7);
    RAISE NOTICE '%', B;

    B := combinacaoLinear(A,3,2,2,2);
    RAISE NOTICE '%', B;

    B := combinacaoLinear(A,2,1,3,2);
    RAISE NOTICE '%', B;

end;$$