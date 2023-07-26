
create trigger check_progetto
before update or delete on dipendente
for each row
execute procedure check_progetto();

create or replace function check_progetto()
returns trigger language plpgsql as $$
    declare
        n integer;
        matr integer;
    begin

        select count(*) into n from (select progetto, count(*) as num_dip 
        from coinvolge 
        where coinvolge.progetto in 
                            (select progetto from coinvolge
                            where coinvolge.matricola = old.matricola)
        group by coinvolge.progetto
        having count(*) = 1) as prog_num;

        if n >= 1 then
            raise notice 'Non è possibile eliminare il dipendente poichè è unico dipendente di alcuni progetti';
            return null;
        end if;

        return old;

    end;

$$;