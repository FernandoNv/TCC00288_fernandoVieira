DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE OR REPLACE FUNCTION multiplyMatrix(A float[][], B float[][]) RETURNS float[][] AS $$
<< outerblock >>
DECLARE
    C float[][] := '{}';
    linha float[] := '{}';
    soma float := 0;
BEGIN

    IF array_length(A,2) <> array_length(B, 1) THEN
        RAISE EXCEPTION 'Numero de colunas da primeira matriz é diferente do numero de linhas da segunda matriz ';
    END IF;

    FOR i IN 1..array_length(A,1) LOOP
        linha := '{}';
        FOR j IN 1..array_length(B,2) LOOP
            soma := 0;
            FOR k IN 1..array_length(B,1) LOOP
                soma := soma + (A[i][k]*B[k][j]);
            END LOOP;
            linha := array_append(linha, soma);
        END LOOP;
        C := array_cat(C, array[linha]);
    END LOOP;


    RETURN C;
END;
$$ LANGUAGE plpgsql;

do $$
declare
    A float[2][2];
    B float[3][2];
    C float[][];

    D float[3][3];
    E float[3][2];
    F float[][];
begin
    
    D := '{
        {1,1,1}, 
        {1,2,1},
        {1,1,3}
    }';

    E := '{
        {3,1}, 
        {1,2},
        {1,1}
    }';

    F := multiplyMatrix(D,E);
    RAISE NOTICE '%', F;


    A := '{
        {2,4}, 
        {1,4}
    }';

    B := '{
        {1,4}, 
        {1,3},
        {1,3}
    }';

    C := multiplyMatrix(A,B);
    RAISE NOTICE '%', C;

end;$$