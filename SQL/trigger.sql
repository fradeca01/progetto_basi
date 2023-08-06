insert into dipendente values (1234, 'orso', 'bruno', '06-08-2020', 'scalatore di specchi', '02-02-2001', '01-01-2014', '01-01-2015',null, 'arrampicata su superfici liscie', 'boh');



-- Trigger 1


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




--Trigger 2

-- Secondo vincolo aziendale: quando aggiorno ultimo fornitore in 
-- Dipartimento devo controllare che ultimo fornitore (old) sia in Fornisce 
-- o sia ultimo fornitore di un altro Dipartimento, se non si verifica, elimino ultimo fornitore (old) da Fornitore

create or replace function check_fornitore()
returns trigger language plpgsql as $$
    declare 
        lastF varchar;
        n1 integer;
        n2 integer;
    begin
        lastF = old.ultimo_acquisto;
        
        -- controllare che lastF sia nella tabella Fornisce o che sia ultimo_fornitore di un altro dip nella tabella Dipartimento
        select count(*) into n1
        from fornisce
        where lastF = fornisce.fornitore;
             
        select count(*) into n2
        FROM dipartimento 
        WHERE dipartimento.ultimo_acquisto = new.nome;

        if n1 = 0 and n2 = 0 then
        --  se non sta devo cancellare il fornitore
            raise notice 'Deleting';
            DELETE FROM fornitore WHERE nome = lastF;
        else
            raise notice 'Not deleting';
        end if;

        return new;
    end;
$$;



create trigger dipartimento 
after delete or update on dipartimento
for each row    
execute procedure check_fornitore();


--Trigger 3


create or replace function check_dipartimento()
returns trigger language plpgsql as $$
    declare 
        n integer;
    begin

        select count(*) into n from dipendente 
        where dipendente.dipartimento = old.dipartimento;
        if n <= 1 then
            raise notice 'Non è possibile eliminare il dipendente...fornisce';
            return null;
        end if;

        return old;
    end;
$$;




create trigger check_dipartimento 
before update or delete on dipendente
for each row    
execute procedure check_dipartimento();


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









create trigger check_progetto
before update or delete on dipendente
for each row
execute procedure check_progetto();



