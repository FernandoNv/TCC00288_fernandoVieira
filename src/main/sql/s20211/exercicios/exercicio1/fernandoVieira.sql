DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE pessoa(
    nome varchar,
    endereco varchar
);

INSERT INTO pessoa VALUES (
    'Fernando', 
    'Rua Rio de Janeiro n1'
);

INSERT INTO pessoa VALUES (
    'Juliana', 
    'Rua Rio de Janeiro n2'
);

INSERT INTO pessoa VALUES (
    'Alessandra', 
    'Rua Rio de Janeiro n3'
);

SELECT * FROM pessoa;
