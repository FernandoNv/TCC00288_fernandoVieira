DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

CREATE TABLE cliente(
    id bigint primary key,
    titular bigint references cliente(id),
    nome varchar not null
);

INSERT INTO cliente VALUES(
    '1',
    NULL,
    'Fernando Vieira'
);

INSERT INTO cliente VALUES(
    '2',
    NULL,
    'Juliana Vieira'
);

INSERT INTO cliente VALUES(
    '3',
    '1',
    'Dependente 1'
);

INSERT INTO cliente VALUES(
    '4',
    '1',
    'Dependente 2'
);

INSERT INTO cliente VALUES(
    '5',
    '2',
    'Dependente 3'
);

INSERT INTO cliente VALUES(
    '6',
    '2',
    'Dependente 4'
);

INSERT INTO cliente VALUES(
    '31',
    NULL,
    'Cliente 3'
);

INSERT INTO cliente VALUES(
    '32',
    NULL,
    'Cliente 4'
);

SELECT * FROM cliente;

CREATE TABLE procedimento(
    id bigint primary key,
    nome varchar not null
);

INSERT INTO procedimento VALUES(
    '7',
    'proc1'
);

INSERT INTO procedimento VALUES(
    '8',
    'proc2'
);

INSERT INTO procedimento VALUES(
    '9',
    'proc3'
);

INSERT INTO procedimento VALUES(
    '10',
    'proc4'
);

SELECT * FROM procedimento;

CREATE TABLE atendimento(
    id bigint primary key,
    "data" timestamp not null,
    proc bigint references procedimento(id) not null,
    cliente bigint not null
);

INSERT INTO atendimento VALUES(
    '11',
    '2021-07-01 22:00:00',
    '7',
    '1'
);

INSERT INTO atendimento VALUES(
    '12',
    '2021-07-02 19:10:25',
    '7',
    '1'
);

INSERT INTO atendimento VALUES(
    '13',
    '2021-07-03 19:10:25',
    '7',
    '1'
);

INSERT INTO atendimento VALUES(
    '14',
    '2021-07-01 22:13:00',
    '8',
    '2'
);

INSERT INTO atendimento VALUES(
    '15',
    '2021-07-02 02:13:00',
    '8',
    '2'
);

INSERT INTO atendimento VALUES(
    '16',
    '2021-07-03 19:13:00',
    '8',
    '2'
);


INSERT INTO atendimento VALUES(
    '17',
    '2021-05-22 20:11:00',
    '9',
    '3'
);

INSERT INTO atendimento VALUES(
    '18',
    '2021-05-23 23:11:00',
    '9',
    '3'
);

INSERT INTO atendimento VALUES(
    '19',
    '2021-05-24 09:30:00',
    '9',
    '3'
);

INSERT INTO atendimento VALUES(
    '20',
    '2021-07-07 11:10:25',
    '10',
    '4'
);

INSERT INTO atendimento VALUES(
    '21',
    '2021-07-07 15:50:15',
    '10',
    '4'
);

INSERT INTO atendimento VALUES(
    '22',
    '2021-07-07 17:10:00',
    '10',
    '4'
);


INSERT INTO atendimento VALUES(
    '23',
    '2021-07-07 23:05:00',
    '8',
    '5'
);


INSERT INTO atendimento VALUES(
    '24',
    '2021-07-08 22:11:25',
    '8',
    '5'
);


INSERT INTO atendimento VALUES(
    '25',
    '2021-07-09 22:30:25',
    '8',
    '5'
);

INSERT INTO atendimento VALUES(
    '26',
    '2021-07-07 22:10:25',
    '9',
    '6'
);

INSERT INTO atendimento VALUES(
    '27',
    '2021-07-08 22:23:25',
    '8',
    '6'
);

INSERT INTO atendimento VALUES(
    '28',
    '2021-07-09 22:10:25',
    '7',
    '6'
);

INSERT INTO atendimento VALUES(
    '29',
    '2021-07-10 22:23:25',
    '8',
    '6'
);

INSERT INTO atendimento VALUES(
    '30',
    '2021-07-11 22:10:25',
    '9',
    '6'
);

INSERT INTO atendimento VALUES(
    '33',
    '2021-07-11 22:10:25',
    '7',
    '31'
);

INSERT INTO atendimento VALUES(
    '34',
    '2021-07-12 22:10:25',
    '8',
    '31'
);

INSERT INTO atendimento VALUES(
    '35',
    '2021-07-12 09:10:25',
    '9',
    '32'
);

INSERT INTO atendimento VALUES(
    '36',
    '2021-07-13 10:10:25',
    '9',
    '32'
);

SELECT * FROM atendimento ORDER BY atendimento.data;
   
CREATE TABLE fato(
    id bigint not null,
    "data" timestamp not null,
    procedimento bigint not null,
    qtd_vidas_contrato int not null,
    qtd_atend_urgencia int not null
);



CREATE OR REPLACE FUNCTION insertFatos() RETURNS SETOF fato AS $$
<<outerblock>>
DECLARE
    atendimentos CURSOR FOR SELECT * FROM atendimento;
    dependentes CURSOR(idTitular bigint) FOR SELECT * FROM cliente WHERE titular = idTitular;
    qtdVidasContrato integer := 1; --inicia com apenas o titular
    qtdAtendUrgencia integer := 0;

    titular bigint;
BEGIN
    FOR a IN atendimentos LOOP
        SELECT cliente.titular INTO STRICT titular FROM cliente WHERE id = a.cliente;
        
        qtdVidasContrato := 1; --inicia com apenas o titular

        IF titular IS NULL THEN
            FOR cliente IN dependentes(a.cliente) LOOP --segundo FOR pedido pela questão
                qtdVidasContrato := qtdVidasContrato + 1;
            END LOOP;
        ELSE
            FOR cliente IN dependentes(titular) LOOP --segundo FOR pedido pela questão
                qtdVidasContrato := qtdVidasContrato + 1;
            END LOOP;
        END IF;
        SELECT COUNT(*) INTO qtdAtendUrgencia 
        FROM atendimento 
        WHERE 
            atendimento.cliente = a.cliente AND 
            atendimento.data < a.data AND 
            atendimento.data::time >= '22:00:00';
        
        EXECUTE format('
            INSERT INTO fato VALUES(
                $1,
                $2,
                $3,
                $4,
                $5
            );
        ')
        USING a.id, a.data, a.proc, qtdVidasContrato, qtdAtendUrgencia;
    END LOOP;

    RETURN QUERY SELECT * FROM fato ORDER BY fato.data;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM insertFatos();