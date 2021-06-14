DO $$ BEGIN
    PERFORM drop_functions();
    PERFORM drop_tables();
END $$;

create table pessoa(
name varchar,
endereco varchar
);

insert into pessoa values ('nome', 'endereco');


select * from pessoa;
