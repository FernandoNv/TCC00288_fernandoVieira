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

INSERT INTO atividade VALUES(
    '1',
    'Atividade 1'
);

INSERT INTO atividade VALUES(
    '2',
    'Atividade 2'
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



CREATE OR REPLACE FUNCTION process_concerto() RETURNS TRIGGER AS $$
    << outerblock >>
    DECLARE
        cont integer := 0;
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            RAISE NOTICE 'DELETING...';
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN

            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            RAISE NOTICE 'INSERTING...';
            --verificar se a arena esta alugada para o horario passado
            SELECT COUNT(*) INTO cont
            FROM concerto
            WHERE inicio >= NEW.inicio AND fim <= NEW.fim AND arena = NEW.arena;
            
            IF(cont >= 1) THEN
                RAISE EXCEPTION 'Arena esta ocupada nesse horario';
                RETURN NULL;
            END IF;

            --verificar se o artista esta ocupado no horario passado
            SELECT COUNT(*) INTO cont
            FROM concerto
            WHERE inicio >= NEW.inicio AND fim <= NEW.fim AND artista = NEW.artista;
            
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
    BEFORE INSERT OR UPDATE OR DELETE ON concerto
    FOR EACH ROW
    EXECUTE PROCEDURE process_concerto();