create or replace function check_dipartimento()
returns trigger language plpgsql as $$
    declare 
        n integer;
    begin

        select count(*) into n from dipendente 
        where dipendente.dipartimento = old.dipartimento;
        if n <= 1 then
            raise notice 'Non è possibile eliminare il dipendente';
            return null;
        end if;

        return old;
    end;
$$;




create trigger check_dipartimento 
before update or delete on dipendente
for each row    
execute procedure check_dipartimento();