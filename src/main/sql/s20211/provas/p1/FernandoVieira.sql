DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table cidade(
numero int not null primary key,
nome varchar not null
);

create table bairro(
numero int not null primary key,
nome varchar not null,
cidade int not null,
foreign key (cidade) references cidade(numero)
);

create table pesquisa(
numero int not null,
descricao varchar not null,
primary key (numero)
);

create table pergunta(
pesquisa int not null,
numero int not null,
descricao varchar not null,
primary key (pesquisa,numero),
foreign key (pesquisa) references pesquisa(numero)
);

create table resposta(
pesquisa int not null,
pergunta int not null,
numero int not null,
descricao varchar not null,
primary key (pesquisa,pergunta,numero),
foreign key (pesquisa,pergunta) references pergunta(pesquisa,numero)
);

create table entrevista(
numero int not null primary key,
data_hora timestamp not null,
bairro int not null,
foreign key (bairro) references bairro(numero)
);

create table escolha(
entrevista int not null,
pesquisa int not null,
pergunta int not null,
resposta int not null,
primary key (entrevista,pesquisa,pergunta),
foreign key (entrevista) references entrevista(numero),
foreign key (pesquisa,pergunta,resposta) references resposta(pesquisa,pergunta,numero)
);

insert into cidade values (1,'Rio de Janeiro');
insert into cidade values (2,'Niterói');
insert into cidade values (3,'São Paulo');

insert into bairro values (1,'Tijuca',1);
insert into bairro values (2,'Centro',1);
insert into bairro values (3,'Lagoa',1);
insert into bairro values (4,'Icaraí',2);
insert into bairro values (5,'São Domingos',2);
insert into bairro values (6,'Santa Rosa',2);
insert into bairro values (7,'Moema',3);
insert into bairro values (8,'Jardim Paulista',3);
insert into bairro values (9,'Higienópolis',3);


insert into pesquisa values (1,'Pesquisa 1');

insert into pergunta values (1,1,'Pergunta 1');
insert into pergunta values (1,2,'Pergunta 2');
insert into pergunta values (1,3,'Pergunta 3');
insert into pergunta values (1,4,'Pergunta 4');

insert into resposta values (1,1,1,'Resposta 1 da pergunta 1');
insert into resposta values (1,1,2,'Resposta 2 da pergunta 1');
insert into resposta values (1,1,3,'Resposta 3 da pergunta 1');
insert into resposta values (1,1,4,'Resposta 4 da pergunta 1');
insert into resposta values (1,1,5,'Resposta 5 da pergunta 1');

insert into resposta values (1,2,1,'Resposta 1 da pergunta 2');
insert into resposta values (1,2,2,'Resposta 2 da pergunta 2');
insert into resposta values (1,2,3,'Resposta 3 da pergunta 2');
insert into resposta values (1,2,4,'Resposta 4 da pergunta 2');
insert into resposta values (1,2,5,'Resposta 5 da pergunta 2');
insert into resposta values (1,2,6,'Resposta 5 da pergunta 2');

insert into resposta values (1,3,1,'Resposta 1 da pergunta 3');
insert into resposta values (1,3,2,'Resposta 2 da pergunta 3');
insert into resposta values (1,3,3,'Resposta 3 da pergunta 3');

insert into resposta values (1,4,1,'Resposta 1 da pergunta 4');
insert into resposta values (1,4,2,'Resposta 2 da pergunta 4');

insert into entrevista values (1,'2020-03-01'::timestamp,1);
insert into escolha values (1,1,1,2);
insert into escolha values (1,1,2,2);
insert into escolha values (1,1,3,1);

insert into entrevista values (2,'2020-03-01'::timestamp,1);
insert into escolha values (2,1,1,3);
insert into escolha values (2,1,2,1);
insert into escolha values (2,1,3,2);

insert into entrevista values (3,'2020-03-01'::timestamp,1);
insert into escolha values (3,1,1,4);
insert into escolha values (3,1,2,1);
insert into escolha values (3,1,3,1);

insert into entrevista values (4,'2020-03-01'::timestamp,1);
insert into escolha values (4,1,1,2);
insert into escolha values (4,1,2,1);
insert into escolha values (4,1,3,1);

insert into entrevista values (5,'2020-03-01'::timestamp,1);
insert into escolha values (5,1,1,2);
insert into escolha values (5,1,2,1);
insert into escolha values (5,1,3,1);

select * from pesquisa;
select * from pergunta;
select * from resposta;
select * from escolha;


CREATE TABLE resultadoTabela(
    pergunta int,
    histograma float[]
);

CREATE OR REPLACE FUNCTION resultado(p_pesquisa int, p_bairros varchar[], p_cidades varchar[]) RETURNS SETOF resultadoTabela AS $$
<<outerblock>>
DECLARE
    perguntas CURSOR FOR SELECT numero, pesquisa FROM pergunta WHERE pergunta.pesquisa = p_pesquisa;
    respostas CURSOR(idPergunta int) 
        FOR SELECT numero 
        FROM resposta 
        WHERE resposta.pesquisa = p_pesquisa AND 
              resposta.pergunta = idPergunta;
    qtdEscolha float := 0;
    qtdEscolhaTotal float := 0;
    media float := 0;
    linha float[] := '{}';
    histograma float[] := '{}';
BEGIN
    FOR pergunta IN perguntas LOOP
        histograma := '{}';
        FOR resposta IN respostas(pergunta.pesquisa) LOOP
            --FAZ A CONTAGEM DE ACORDO COM CADA RESPOSTA
            SELECT COUNT(*) INTO qtdEscolha 
            FROM escolha 
            WHERE escolha.pergunta = pergunta.numero AND
                  escolha.pesquisa = p_pesquisa AND
                  escolha.resposta = resposta.numero;

            SELECT COUNT(*) INTO qtdEscolhaTotal 
            FROM escolha 
            WHERE escolha.pergunta = pergunta.numero AND
                  escolha.pesquisa = p_pesquisa;

        IF qtdEscolhaTotal = 0 THEN
            media := 0;
        ELSE
            media := qtdEscolha/qtdEscolhaTotal;
        END IF;
        linha := '{}';
        linha := array_append(linha, resposta.numero::FLOAT);
        linha := array_append(linha, media::FLOAT);

        histograma := array_cat(histograma, ARRAY[linha]);
        END LOOP;
        --INSERE OS DADOS DO HISTOGRAMA
        
        EXECUTE format('
            INSERT INTO resultadoTabela VALUES(
                $1,
                $2
            );
        ')
        USING pergunta.numero, histograma;
    END LOOP;

    RETURN QUERY SELECT * FROM resultadoTabela;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM resultado('1', '{Bairro1, Bairro2}', '{Rio de Janeiro, São Paulo}');