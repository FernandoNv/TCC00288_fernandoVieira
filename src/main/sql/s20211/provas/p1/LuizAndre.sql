DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table venda(
    ano_mes int not null,
    unidade int,
    vendedor int,
    produto int,
    valor float
);


insert into venda values(202001,1,1,10,100.0);
insert into venda values(202001,1,2,10,200.0);
insert into venda values(202001,1,3,10,300.0);
insert into venda values(202002,1,1,10,200.0);
insert into venda values(202002,1,2,10,300.0);
insert into venda values(202002,1,3,10,500.0);
insert into venda values(202003,1,1,10,900.0);
insert into venda values(202003,1,2,10,200.0);
insert into venda values(202003,1,3,10,500.0);
insert into venda values(202004,1,1,10,200.0);
insert into venda values(202004,1,2,10,150.0);
insert into venda values(202004,1,3,10,500.0);
insert into venda values(202005,1,1,10,500.0);
insert into venda values(202005,1,2,10,300.0);
insert into venda values(202005,1,3,10,700.0);
insert into venda values(202006,1,1,10,200.0);
insert into venda values(202006,1,2,10,200.0);
insert into venda values(202006,1,3,10,200.0);



-----------------------------------------
--
-- Acrescente seu código a partir daqui
-----------------------------------------
