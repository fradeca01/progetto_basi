create or replace function check_qualifica(el1 varchar(100), el2 varchar(100))
returns boolean language plpgsql as $$
    begin

    if (el2 is not null) then
        return (el1 is not null);
    else 
        return true;
    end if;

    end
$$; 