DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE restaurante ( 
    cnpj integer NOT NULL, 
    endereco character varying NOT NULL, 
    CONSTRAINT rest_pk
        PRIMARY KEY (cnpj)
); 
 

CREATE TABLE prato ( 
    prato_id integer NOT NULL, 
    nome character varying NOT NULL, 
    CONSTRAINT prato_pk
        PRIMARY KEY (prato_id)
);

CREATE TABLE menu ( 
    cnpj integer NOT NULL, 
    prato_id integer NOT NULL, 
    preco real NOT NULL, 
    CONSTRAINT menu_pk
        PRIMARY KEY(cnpj, prato_id), 
    CONSTRAINT menu_rest_fk
        FOREIGN KEY(cnpj)
        REFERENCES restaurante (cnpj),
    CONSTRAINT menu_prato_fk
        FOREIGN KEY(prato_id)
        REFERENCES prato (prato_id)
); 

CREATE TABLE pedido(
    pedido_id integer NOT NULL,
    cnpj integer NOT NULL,
    CONSTRAINT pedido_pk 
        PRIMARY KEY(pedido_id),
    CONSTRAINT pedido_rest_fk 
        FOREIGN KEY(cnpj) 
        REFERENCES restaurante(cnpj)
);

CREATE TABLE item_pedido (
    pedido_id integer NOT NULL, 
    item integer NOT NULL, 
    cnpj integer NOT NULL,
    prato_id integer NOT NULL, 
    qtd integer NOT NULL, 
    CONSTRAINT item_pk 
        PRIMARY KEY (pedido_id, item), 
    CONSTRAINT item_pedido_fk 
        FOREIGN KEY (pedido_id) 
        REFERENCES pedido(pedido_id), 
    CONSTRAINT item_menu_fk 
        FOREIGN KEY(cnpj, prato_id) 
        REFERENCES menu(cnpj, prato_id)
);

-- Criar triggers para auxiliar a restrição de integridade que garante a consistencia
-- dos pedidos no que se refere somente a unicidade de restaurante do pedido.

CREATE OR REPLACE FUNCTION process_item_pedido() RETURNS TRIGGER AS $$
    << outerblock >>
    DECLARE
        cont integer := 0;
        cnpj integer := 0;
    BEGIN
        IF (TG_OP = 'DELETE') THEN
            RAISE NOTICE 'DELETING...';
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            RAISE NOTICE 'UPDATING...';
            SELECT pedido.cnpj INTO cnpj 
            FROM pedido 
            WHERE pedido.pedido_id = NEW.pedido_id;

            IF(cnpj = NEW.cnpj) THEN
                RETURN NEW;
            END IF;
            
            --NAO DEIXA FAZER O UPDATING SE O CNPJ DO PEDIDO NAO FOR IGUAL AO DO NOVO ITEM_PEDIDO
            RETURN NULL;
        ELSIF (TG_OP = 'INSERT') THEN
            RAISE NOTICE 'INSERTING...';
            SELECT COUNT(*) INTO cont 
            FROM pedido 
            WHERE pedido.cnpj = NEW.cnpj AND pedido.pedido_id = NEW.pedido_id;
            
            IF(cont = 1) THEN
                RAISE NOTICE 'INSERTING...';
                RETURN NEW;
            ELSE
                RAISE EXCEPTION 'O CNPJ DO RESTAURANTE EM ITEM_PEDIDO DEVE SER IGUAL AO DO PEDIDO';
            END IF;
            RETURN NULL;
        END IF;
        RETURN NULL;
    END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_item_pedido
    BEFORE INSERT OR UPDATE OR DELETE ON item_pedido
    FOR EACH ROW
    EXECUTE PROCEDURE process_item_pedido();
    

CREATE OR REPLACE FUNCTION process_pedido() RETURNS TRIGGER AS $$
    << outerblock >>
    DECLARE
    BEGIN
        RAISE NOTICE 'UPDATING...';
        UPDATE item_pedido 
        SET cnpj = NEW.cnpj, pedido_id = NEW.pedido_id
        WHERE pedido_id = OLD.pedido_id 
            AND cnpj = OLD.cnpj;

        RETURN NEW;
    END; 
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_pedido
    AFTER UPDATE ON pedido
    FOR EACH ROW
    EXECUTE PROCEDURE process_pedido();

INSERT INTO restaurante(cnpj, endereco)
VALUES('1', 'Rua do Restaurante 1');

INSERT INTO restaurante(cnpj, endereco) 
VALUES('2', 'Rua do Restaurante 2');

INSERT INTO prato(prato_id, nome) 
VALUES('1','Feijoada');

INSERT INTO prato(prato_id, nome) 
VALUES('2', 'Batata Frita');

INSERT INTO menu(cnpj, prato_id, preco)
VALUES('1','1','29.99');

INSERT INTO menu(cnpj, prato_id, preco)
VALUES('1','2','19.99');

INSERT INTO menu(cnpj, prato_id, preco)
VALUES('2','1','25.99');

INSERT INTO menu(cnpj, prato_id, preco)
VALUES('2','2','15.99');

INSERT INTO pedido(pedido_id, cnpj)
VALUES('1','1');

INSERT INTO pedido(pedido_id, cnpj)
VALUES('2','1');

INSERT INTO pedido(pedido_id, cnpj)
VALUES('3','2');

INSERT INTO item_pedido(pedido_id, item, cnpj, prato_id, qtd) 
VALUES('1','1','1','1', '1');

INSERT INTO item_pedido(pedido_id, item, cnpj, prato_id, qtd) 
VALUES('1','2','1','2', '1');

--DEVE DAR ERRO: CNPJ DIFERENTE DO PEDIDO
INSERT INTO item_pedido(pedido_id, item, cnpj, prato_id, qtd) 
VALUES('2','3','2','2', '5');

INSERT INTO item_pedido(pedido_id, item, cnpj, prato_id, qtd) 
VALUES('2','3','1','2','5');

INSERT INTO item_pedido(pedido_id, item, cnpj, prato_id, qtd) 
VALUES('3','4','2','1','3');

SELECT * FROM pedido;
SELECT * FROM item_pedido;

UPDATE pedido
SET cnpj = '2'
WHERE pedido_id = '1';

SELECT * FROM pedido;
SELECT * FROM item_pedido;
