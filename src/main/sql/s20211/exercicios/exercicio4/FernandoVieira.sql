DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE OR REPLACE FUNCTION removeRowCol(m FLOAT[][], i INTEGER, j INTEGER) RETURNS FLOAT[][] AS $$
<< outerblock >>
DECLARE
    resultado FLOAT[][] := '{}';
    linha FLOAT[] := '{}';
BEGIN
    FOR r IN 1..array_length(m,1) LOOP
        IF r <> i THEN
            linha := '{}';
            FOR c IN 1..array_length(m,2) LOOP
                IF c <> j THEN
                    linha := array_append(linha, m[r][c]);
                END IF;
            END LOOP;
            resultado := array_cat(resultado, array[linha]);
        END IF;
    END LOOP;

    RETURN resultado;
END;
$$ LANGUAGE plpgsql;

do $$
declare
    A float[5][5];
    B float[][];
    
    C float[4][3];
    D float[][];
    
    E float[3][2];
    F float[][];
begin

    A := '{
        {1,2,3,4,5},
        {6,7,8,9,10},
        {11,12,13,14,15},
        {16,17,18,19,20},
        {21,22,23,24,25}
    }';
    
    C := '{
        {1,2,3},
        {4,5,6},
        {7,8,9},
        {10,11,12}
    }';

    E := '{
        {1,2},
        {3,4},
        {5,6}
    }';

    B := removeRowCol(A,1,1);
    RAISE NOTICE 'B: %', B;

    D := removeRowCol(C,2,3);
    RAISE NOTICE 'D: %', D;

    F := removeRowCol(E,3,2);
    RAISE NOTICE 'F: %', F;
end;$$