create or replace function check_competenza()
returns trigger language plpgsql as $$
    declare 
        matr integer;
        comp varchar;
        n integer;
    begin
        matr = new.matricola;
        comp = new.competenza;

        select count(*) into n from Possiede
        where Possiede.matricola = matr and Possiede.competenza = comp;

        if n = 0 then
            raise notice 'Dipendente non ha tale Competenza';
            return null;
        end if;

        raise notice 'OKKK';

        return new;
    end;
$$;


create trigger coinvolge before insert or update 
on coinvolge
for each row    
execute procedure check_competenza();
