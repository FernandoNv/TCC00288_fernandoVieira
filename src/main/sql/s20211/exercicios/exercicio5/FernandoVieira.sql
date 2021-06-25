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

CREATE OR REPLACE FUNCTION determinant(A FLOAT[][]) RETURNS FLOAT AS $$
<< outerblock >>
DECLARE
    det FLOAT := 0;
BEGIN
    IF array_length(A,1) <> array_length(A,2) THEN
        RAISE EXCEPTION 'Só podemos calcular o determinante em matrizes quadradas';
    END IF;
    
    --CASO 1x1
    IF array_length(A,1) = 1 THEN
        return A[1][1];
    END IF;

    --CASO 2X2
    IF array_length(A, 1) = 2  THEN
        return A[1][1]*A[2][2] - A[1][2]*A[2][1];
    END IF;
    
    --percorrer pela primeira linha
    FOR col IN 1..array_length(A,2) LOOP
        IF A[1][col] <> 0 THEN
            det = det + A[1][col]*POW(-1,1+col)*determinant(removeRowCol(A,1,col));
        END IF;
    END LOOP;
    
    RETURN det;
END;
$$ LANGUAGE plpgsql;

do $$
declare
    
    A FLOAT[2][2];
    B FLOAT[3][3];
    C FLOAT[4][4];
    D FLOAT[5][5];
    E FLOAT[6][6];
    F FLOAT[7][7];
    G FLOAT[8][8];
    H FLOAT[9][9];
    I FLOAT[1][2];

    det FLOAT := 0;
begin

    A := '{
        {5,3},
        {1,4}
    }';
    
    det := determinant(A);
    RAISE NOTICE 'det: %', det;

    B := '{
        {5,3,2},
        {1,4,7},
        {13,11,9}
    }';
    
    det := determinant(B);
    RAISE NOTICE 'det: %', det;

    C := '{
        {5,3,2,7},
        {1,4,7,11},
        {13,11,9,13},
        {21,23,29,31}
    }';
    
    det := determinant(C);
    RAISE NOTICE 'det: %', det;

    D := '{
        {5,3,2,7,11},
        {1,4,7,11,13},
        {13,11,9,13,17},
        {21,23,29,31,31},
        {12,32,92,13,21}
    }';
    
    det := determinant(D);
    RAISE NOTICE 'det: %', det;

    E := '{
        {5,3,2,7,11,43},
        {1,4,7,11,13,49},
        {13,11,9,13,17,23},
        {21,23,29,31,31,53},
        {12,32,92,13,21,1},
        {3,14,35,7,2,55}
    }';
    
    det := determinant(E);
    RAISE NOTICE 'det: %', det;

    F := '{
        {5,3,2,7,11,43,2},
        {1,4,7,11,13,49,3},
        {13,11,9,13,17,23,4},
        {21,23,29,31,31,53,5},
        {12,32,92,13,21,1,6},
        {3,14,35,7,2,55,7},
        {20,10,5,10,20,25,8}
    }';
    
    det := determinant(F);
    RAISE NOTICE 'det: %', det;

    G := '{
        {1,2,3,4,5,6,7,8},
        {1,1,2,2,3,3,4,4},
        {1,1,1,1,2,2,2,2},
        {1,1,1,1,1,1,1,1},
        {2,2,2,2,2,2,2,2},
        {3,3,3,3,3,3,3,3},
        {4,4,4,4,4,4,4,4},
        {5,5,5,5,5,5,5,5}
    }';
    
    det := determinant(G);
    RAISE NOTICE 'det: %', det;

    H := '{
        {1,0,0,0,0,0,0,0,0},
        {0,1,0,0,0,0,0,0,0},
        {0,0,1,0,0,0,0,0,0},
        {0,0,0,1,0,0,0,0,0},
        {0,0,0,0,1,0,0,0,0},
        {0,0,0,0,0,1,0,0,0},
        {0,0,0,0,0,0,1,0,0},
        {0,0,0,0,0,0,0,1,0},
        {0,0,0,0,0,0,0,0,1}
    }';
    
    det := determinant(H);
    RAISE NOTICE 'det: %', det;

    --I := '{
    --    {1,2}
    --}';
    --
    --det := determinant(I);
    --RAISE NOTICE 'det: %', det;
end;$$