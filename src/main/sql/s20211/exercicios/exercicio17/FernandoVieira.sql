DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

DROP TABLE IF EXISTS produto CASCADE;
CREATE TABLE produto(
    codigo varchar,
    descricao varchar,
    preco float,
    CONSTRAINT produto_pk PRIMARY KEY(codigo)
);

INSERT INTO produto VALUES(
    '1',
    'ps1',
    '200'
);

INSERT INTO produto VALUES(
    '2',
    'ps2',
    '400'
);

INSERT INTO produto VALUES(
    '3',
    'ps3',
    '1000'
);


INSERT INTO produto VALUES(
    '4',
    'ps4',
    '2000'
);

INSERT INTO produto VALUES(
    '5',
    'ps5',
    '5000'
);

SELECT * FROM produto;

CREATE OR REPLACE FUNCTION valorPedido(p_produtos varchar[], p_qtds integer[]) RETURNS float AS $$
<< outerblock >>
DECLARE
    r RECORD;
    preco float;
    soma float := 0;
BEGIN
    FOR r IN 
        SELECT t.* FROM unnest(p_produtos, p_qtds) AS t(codigo, qtd)
    LOOP
        SELECT produto.preco INTO STRICT preco 
            FROM produto WHERE produto.codigo = r.codigo;
        soma := soma + (preco*r.qtd);
    END LOOP;

    RETURN soma;
END;
$$ LANGUAGE plpgsql;

do $$
declare
    p_produtos varchar[];
    q_qtds integer[];
    soma float := 0;
begin
    
    p_produtos = '{1, 2, 3}';
    q_qtds = '{1, 1, 1}';

    soma = valorPedido(p_produtos, q_qtds);
    RAISE NOTICE '%', soma;

    p_produtos = '{1, 2, 3, 4, 5}';
    q_qtds = '{1, 2, 3, 4, 5}';

    soma = valorPedido(p_produtos, q_qtds);
    RAISE NOTICE '%', soma;

    p_produtos = '{1, 3, 5}';
    q_qtds = '{1, 3, 1}';

    soma = valorPedido(p_produtos, q_qtds);
    RAISE NOTICE '%', soma;

    p_produtos = '{5, 3}';
    q_qtds = '{10, 2}';

    soma = valorPedido(p_produtos, q_qtds);
    RAISE NOTICE '%', soma;
end;$$