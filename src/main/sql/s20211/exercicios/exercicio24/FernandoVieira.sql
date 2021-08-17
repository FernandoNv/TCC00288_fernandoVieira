DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;


CREATE TABLE hotel(
    numero integer NOT NULL,
    nome TEXT NOT NULL,
    CONSTRAINT hotel_pk 
        PRIMARY KEY(numero)
);

CREATE TABLE reserva(
    numero integer NOT NULL,
    hotel integer NOT NULL,
    cpf_cnpj integer NOT NULL,
    inicio timestamp NOT NULL,
    fim timestamp NOT NULL,
    CONSTRAINT reserva_pk 
        PRIMARY KEY(numero),
    CONSTRAINT reserva_hotel_fk
        FOREIGN KEY(hotel)
        REFERENCES hotel(numero)
);

CREATE TABLE estadia(
    numero integer NOT NULL,
    quarto text NOT NULL,
    inicio timestamp NOT NULL,
    fim timestamp,
    CONSTRAINT estadia_pk 
        PRIMARY KEY(numero),
    CONSTRAINT estadia_reserva_fk
        FOREIGN KEY(numero)
        REFERENCES reserva(numero) ON DELETE RESTRICT ON UPDATE CASCADE 
);

INSERT INTO hotel(numero, nome)
VALUES('1', 'Hotel 1');
INSERT INTO hotel(numero, nome)
VALUES('2', 'Hotel 2');
SELECT * FROM hotel;


CREATE OR REPLACE FUNCTION process_reserva() RETURNS TRIGGER AS $$
    <<outerblock>>
    DECLARE
    BEGIN
        NEW.fim = NEW.fim + interval '1 day' -  interval '1 second';
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER reserva_trigger
    BEFORE INSERT ON reserva
    FOR EACH ROW
    EXECUTE PROCEDURE process_reserva();

INSERT INTO reserva(numero, hotel, cpf_cnpj, inicio, fim)
VALUES('1', '1', '100100100', CURRENT_DATE, CURRENT_DATE + 5);

INSERT INTO reserva(numero, hotel, cpf_cnpj, inicio, fim)
VALUES('2', '2', '100100100', CURRENT_DATE, CURRENT_DATE + 2);

INSERT INTO reserva(numero, hotel, cpf_cnpj, inicio, fim)
VALUES('3', '1', '100100100', CURRENT_DATE+2, CURRENT_DATE+3);

SELECT * FROM reserva;

-- uma estadia só pode acontecer no periodo da reserva
-- a estadia pode nao ser durante todo o periodo da reserva
-- e so podemos fazer a estadia ate o final do primeiro dia da reserva
CREATE OR REPLACE FUNCTION verificaDataEstadia(inicio_reserva timestamp, fim_reserva timestamp, inicio_estadia timestamp, fim_estadia timestamp) RETURNS BOOLEAN AS $$
    BEGIN
        --RAISE NOTICE '% ', date_trunc('day', inicio_reserva);
        --RAISE NOTICE '% ', date_trunc('day', inicio_estadia);
        RETURN (date_trunc('day', inicio_reserva) = date_trunc('day', inicio_estadia)) AND (fim_estadia IS NULL OR (date_trunc('day', fim_reserva) >= date_trunc('day', fim_estadia)));
    END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION process_estadia() RETURNS TRIGGER AS $$
    << outerblock >>
    DECLARE
    reserva_record RECORD;
    BEGIN
        IF (TG_OP = 'UPDATE') THEN
            SELECT numero, inicio, fim INTO STRICT reserva_record 
            FROM reserva 
            WHERE numero = OLD.numero;
            
            If(NEW.fim IS NOT NULL) THEN
                NEW.fim = NEW.fim + interval '1 day' -  interval '1 second';
            END IF;
            
            IF(verificaDataEstadia(reserva_record.inicio, reserva_record.fim, NEW.inicio, NEW.fim)) THEN
                RETURN NEW;
            END IF;
            RAISE EXCEPTION 'O intervalo da estadia deve estar contido no intervalo da reserva';
            --NAO DEIXA FAZER O UPDATING SE A DATA NAO SEGUE AS REGRAS
            RETURN NULL;
        ELSIF (TG_OP = 'INSERT') THEN
            RAISE NOTICE 'INSERTING...';
            
            SELECT numero, inicio, fim INTO STRICT reserva_record 
            FROM reserva 
            WHERE numero = NEW.numero;
            
            If(NEW.fim IS NOT NULL) THEN
                NEW.fim = NEW.fim + interval '1 day' -  interval '1 second';
            END IF;

            IF(verificaDataEstadia(reserva_record.inicio, reserva_record.fim, NEW.inicio, NEW.fim)) THEN
                RETURN NEW;
            END IF;
            
            RAISE EXCEPTION 'O intervalo da estadia deve estar contido no intervalo da reserva';
            --NAO DEIXA FAZER O INSERT SE A DATA NAO SEGUE AS REGRAS
            RETURN NULL;
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER estadia_trigger
    BEFORE INSERT OR UPDATE ON estadia
    FOR EACH ROW
    EXECUTE PROCEDURE process_estadia();

--vai aceitar
INSERT INTO estadia(numero, quarto, inicio, fim)
VALUES('1', 'Q100', CURRENT_DATE, NULL);

--vai dar erro
INSERT INTO estadia(numero, quarto, inicio, fim)
VALUES('2', '100A', CURRENT_DATE+1, CURRENT_DATE + 2); 

--vai dar erro
INSERT INTO estadia(numero, quarto, inicio, fim)
VALUES('2', '100A', CURRENT_DATE, CURRENT_DATE + 3); 

--vai aceitar
INSERT INTO estadia(numero, quarto, inicio, fim)
VALUES('2', '100A', CURRENT_DATE, CURRENT_DATE + 2); 

SELECT * FROM estadia;

--vai dar erro
UPDATE estadia
SET inicio = CURRENT_DATE + 2
WHERE numero = '1';

--vai dar erro
UPDATE estadia
SET fim = CURRENT_DATE + 6
WHERE numero = '1';

--vai dar certo
UPDATE estadia
SET fim = CURRENT_DATE + 3
WHERE numero = '1';

--vai dar certo
INSERT INTO estadia(numero, quarto, inicio, fim)
VALUES('3', '200A', CURRENT_DATE+2, CURRENT_DATE+3); 

SELECT * FROM estadia;