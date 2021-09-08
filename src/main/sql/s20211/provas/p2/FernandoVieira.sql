DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table atividade(
    id int not null primary key,
    nome varchar not null
);

create table artista(
    id int not null primary key,
    nome varchar not null,
    cidade varchar not null,
    estado varchar not null,
    cep int not null,
    atividade int not null,
    CONSTRAINT artista_atividade_fk
        FOREIGN KEY(atividade)
        REFERENCES atividade(id)
);

create table arena(
    id int not null primary key,
    nome varchar not null,
    cidade varchar not null,
    capacidade int not null
);

create table concerto(
    id int not null primary key,
    artista int not null,
    arena int not null,
    inicio timestamp not null,
    fim timestamp not null,
    preco real not null,
    CONSTRAINT concerto_artista_fk
        FOREIGN KEY(artista)
        REFERENCES artista(id),
    CONSTRAINT concerto_arena_fk
        FOREIGN KEY(arena)
        REFERENCES arena(id)
);

CREATE OR REPLACE FUNCTION process_concerto() RETURNS TRIGGER AS $$
    << outerblock >>
    DECLARE
        cont integer := 0;
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            RAISE NOTICE 'DELETING...';
            RETURN OLD;
        ELSIF (TG_OP = 'INSERT' OR TG_OP = 'UPDATE') THEN
            RAISE NOTICE 'INSERTING...';
            --verificar se a arena esta alugada para o horario passado
            SELECT COUNT(*) INTO cont
            FROM concerto
            WHERE arena = NEW.arena AND ((NEW.inicio >= inicio AND NEW.fim <= fim) OR (NEW.inicio < inicio AND NEW.fim <= fim));
            
            IF(cont >= 1) THEN
                RAISE EXCEPTION 'Arena esta ocupada nesse horario';
                RETURN NULL;
            END IF;
            
            --verificar se o artista esta ocupado no horario passado
            SELECT COUNT(*) INTO cont
            FROM concerto
            WHERE artista = NEW.artista AND ((NEW.inicio >= inicio AND NEW.fim <= fim) OR (NEW.inicio < inicio AND NEW.fim <= fim));
            
            IF(cont >= 1) THEN
                RAISE EXCEPTION 'Artista esta ocupado nesse horario';
                RETURN NULL;
            END IF;

            RETURN NEW;
        END IF;
        RETURN NULL;
    END; 
$$ LANGUAGE plpgsql;


CREATE TRIGGER concerto_trigger
    BEFORE INSERT OR UPDATE ON concerto
    FOR EACH ROW
    EXECUTE PROCEDURE process_concerto();

CREATE OR REPLACE FUNCTION process_atividade_excluir() RETURNS TRIGGER AS $$
    << outerblock >>
    DECLARE
        cont integer := 0;
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            RAISE NOTICE 'DELETING...';
            SELECT COUNT(*) INTO cont
            FROM artista
            WHERE atividade = OLD.id;
            
            IF(cont >= 1) THEN
                RAISE EXCEPTION 'A atividade nao pode ser apagada porque existe ao menos um artista exercendo ela';
                RETURN NULL;
            END IF;

            RETURN OLD;
        END IF;
        RETURN NULL;
    END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER atividade_excluir_trigger
    BEFORE DELETE ON atividade
    FOR EACH ROW
    EXECUTE PROCEDURE process_atividade_excluir();

INSERT INTO atividade VALUES(
    '1',
    'Atividade 1'
);

INSERT INTO atividade VALUES(
    '2',
    'Atividade 2'
);

INSERT INTO atividade VALUES(
    '3',
    'Atividade 3'
);

INSERT INTO artista VALUES(
    '1',
    'Fernando Vieira',
    'Rio de Janeiro',
    'RJ',
    '11122233',
    '1'
);

INSERT INTO artista VALUES(
    '2',
    'Juliana Vieira',
    'Rio de Janeiro',
    'RJ',
    '33311122',
    '2'
);

INSERT INTO artista VALUES(
    '3',
    'Alessandra Nascimento',
    'Rio de Janeiro',
    'RJ',
    '88888888',
    '1'
);

INSERT INTO arena VALUES(
    '1',
    'Arena 1',
    'Rio de Janeiro',
    '12000'
);

INSERT INTO arena VALUES(
    '2',
    'Arena 2',
    'Rio de Janeiro',
    '5000'
);

INSERT INTO concerto VALUES(
    '1',
    '1',
    '1',
    '2021-09-08 15:00:00',
    '2021-09-08 20:00:00',
    '100.00'
);

INSERT INTO concerto VALUES(
    '2',
    '2',
    '2',
    '2021-09-08 21:00:00',
    '2021-09-08 22:00:00',
    '100.00'
);

INSERT INTO concerto VALUES(
    '3',
    '3',
    '1',
    '2021-09-10 12:00:00',
    '2021-09-10 13:00:00',
    '100.00'
);

--deve dar erro arena ocupada
INSERT INTO concerto VALUES(
    '4',
    '2',
    '1',
    '2021-09-08 15:00:00',
    '2021-09-08 17:00:00',
    '100.00'
);

--deve dar erro artista ocupado
INSERT INTO concerto VALUES(
    '4',
    '2',
    '1',
    '2021-09-08 20:30:00',
    '2021-09-08 22:00:00',
    '100.00'
);


select * from concerto;

--tem q dar certo
DELETE FROM atividade WHERE id = '3';

--tem q dar erro - ao menos um artista com essa atividade
DELETE FROM atividade WHERE id = '1';

--tem q dar erro - ao menos um artista com essa atividade
DELETE FROM atividade WHERE id = '2';