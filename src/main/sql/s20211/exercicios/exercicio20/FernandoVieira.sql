DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE empregado(
    nome varchar not null primary key,
    salario int not null 
);

CREATE TABLE auditoria(
    alteracao char(1) not null,
    codusuario varchar not null,
    dataalteracao timestamp not null,
    nomeanterior varchar,
    salarioanterior int,
    nomedepois varchar,
    salariodepois int 
);

CREATE OR REPLACE FUNCTION insert_auditoria() RETURNS TRIGGER AS $$
    DECLARE 
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO auditoria VALUES('D', user, now(), OLD.*, NEW.*);
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO auditoria VALUES('A', user, now(), OLD.*, NEW.*);
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO auditoria VALUES('I', user, now(), OLD.*, NEW.*);
            RETURN NEW;
        END IF;
        RETURN NULL;
    END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER emp_auditoria
AFTER INSERT OR UPDATE OR DELETE ON empregado
FOR EACH ROW EXECUTE PROCEDURE insert_auditoria();

INSERT INTO empregado VALUES(
    'Fernando',
    '9999'
);

INSERT INTO empregado VALUES(
    'Juliana',
    '8888'
);

INSERT INTO empregado VALUES(
    'Alessandra',
    '7777'
);

UPDATE empregado
SET nome = 'Fernando do Nascimento'
WHERE nome = 'Fernando';

UPDATE empregado
SET salario = '820000'
WHERE nome = 'Juliana';

UPDATE empregado
SET nome = 'Alessandra do Nascimento', salario = '100000'
WHERE nome = 'Alessandra';

select * from empregado;
DELETE FROM empregado;
select * from auditoria;
 