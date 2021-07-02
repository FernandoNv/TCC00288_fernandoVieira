DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

DROP TABLE IF EXISTS campeonato CASCADE;
CREATE TABLE campeonato(
    codigo TEXT NOT NULL,
    nome TEXT NOT NULL,
    ano INTEGER NOT NULL,
    CONSTRAINT campeonato_pk PRIMARY KEY(codigo)
);

DROP TABLE IF EXISTS time_ CASCADE;
CREATE TABLE time_ (
    sigla TEXT NOT NULL,
    nome TEXT NOT NULL,
    CONSTRAINT time_pk PRIMARY KEY(sigla)
);

DROP TABLE IF EXISTS jogo CASCADE;
CREATE TABLE jogo (
    campeonato TEXT NOT NULL,
    numero INTEGER NOT NULL,
    time1 TEXT NOT NULL,
    time2 TEXT NOT NULL,
    gols1 INTEGER NOT NULL,
    gols2 INTEGER NOT NULL,
    data_ DATE NOT NULL,
    CONSTRAINT jogo_pk PRIMARY KEY(campeonato, numero),
    CONSTRAINT jogo_campeonato_fk 
        FOREIGN KEY(campeonato) REFERENCES campeonato(codigo),
    CONSTRAINT jogo_time_fk1 
        FOREIGN KEY(time1) REFERENCES time_(sigla),
    CONSTRAINT jogo_time_fk2 
        FOREIGN KEY(time2) REFERENCES time_(sigla)
);

--campeonatos
INSERT INTO campeonato VALUES(
    'C21',
    'Campeonato Carioca',
    '2021'
);

INSERT INTO campeonato VALUES(
    'C22',
    'Campeonato Carioca',
    '2022'
);

SELECT * FROM campeonato;

--times
INSERT INTO time_ VALUES(
    'BOT',
    'BOTAFOGO'
);

INSERT INTO time_ VALUES(
    'FLU',
    'FLUMINENSE'
);

INSERT INTO time_ VALUES(
    'VAS',
    'VASCO'
);

INSERT INTO time_ VALUES(
    'FLA',
    'FLAMENGO'
);

SELECT * FROM time_;

--partidas 
--carioca2021
INSERT INTO jogo VALUES(
    'C21',
    '1',
    'BOT',
    'FLU',
    '3',
    '1',
    '01/01/2021'
);

INSERT INTO jogo VALUES(
    'C21',
    '2',
    'VAS',
    'FLA',
    '4',
    '2',
    '01/01/2021'
);

INSERT INTO jogo VALUES(
    'C21',
    '3',
    'FLA',
    'BOT',
    '2',
    '3',
    '04/01/2021'
);

INSERT INTO jogo VALUES(
    'C21',
    '4',
    'FLU',
    'VAS',
    '5',
    '1',
    '04/01/2021'
);

INSERT INTO jogo VALUES(
    'C21',
    '5',
    'BOT',
    'VAS',
    '5',
    '1',
    '07/01/2021'
);

INSERT INTO jogo VALUES(
    'C21',
    '6',
    'FLU',
    'FLA',
    '1',
    '0',
    '07/01/2021'
);

--carioca2022
INSERT INTO jogo VALUES(
    'C22',
    '7',
    'BOT',
    'FLU',
    '0',
    '0',
    '01/01/2022'
);

INSERT INTO jogo VALUES(
    'C22',
    '8',
    'VAS',
    'FLA',
    '2',
    '3',
    '01/01/2022'
);

INSERT INTO jogo VALUES(
    'C22',
    '9',
    'FLA',
    'BOT',
    '3',
    '3',
    '04/01/2022'
);

INSERT INTO jogo VALUES(
    'C22',
    '10',
    'FLU',
    'VAS',
    '5',
    '1',
    '04/01/2022'
);

INSERT INTO jogo VALUES(
    'C22',
    '11',
    'BOT',
    'VAS',
    '1',
    '1',
    '07/01/2022'
);

INSERT INTO jogo VALUES(
    'C22',
    '12',
    'FLU',
    'FLA',
    '0',
    '4',
    '07/01/2022'
);

SELECT * FROM jogo;

--tabela pra auxiliar no retorno dos dados
CREATE TABLE tabela (
    campeonato text,
    time text, 
    pontos numeric, 
    vitorias numeric
);

CREATE OR REPLACE FUNCTION tabelaCampeonato(campeonato text, posInicial integer, posFinal integer) RETURNS SETOF tabela AS $$
<< outerblock >>
DECLARE
    --quantidade de tuplas a serem mostradas
    quantidade integer := posFinal-posInicial+1;
BEGIN
    RETURN QUERY EXECUTE format('
        SELECT campeonato, time, SUM(pontos) as pontos, SUM(vitorias) as vitorias
        FROM(
            SELECT
                campeonato,
                time1 AS time,
                SUM(CASE
                        WHEN gols1 > gols2 THEN 3
                        WHEN gols1 = gols2 THEN 1
                        ELSE 0
                END) AS pontos,
                SUM(CASE
                        WHEN gols1 > gols2 THEN 1
                        ELSE 0
                END) AS vitorias
            FROM jogo
            WHERE campeonato = $1
            GROUP BY campeonato, time1

            UNION ALL

            SELECT
                campeonato,
                time2 AS time,
                SUM(CASE
                        WHEN gols2 > gols1 THEN 3
                        WHEN gols2 = gols1 THEN 1
                        ELSE 0
                END) AS pontos,
                SUM(CASE
                        WHEN gols2 > gols1 THEN 1
                        ELSE 0
                END) AS vitorias
            FROM jogo
            WHERE campeonato = $1
            GROUP BY campeonato, time2

        ) AS tabela
        GROUP BY campeonato, time 
        ORDER BY campeonato, SUM(pontos) DESC, SUM(vitorias) DESC
        LIMIT $2 OFFSET $3;
    ')
    USING campeonato, quantidade, (posInicial-1);
END;
$$ LANGUAGE plpgsql;
   
SELECT * FROM tabelaCampeonato('C21','1','4');
SELECT * FROM tabelaCampeonato('C22','1','4');
