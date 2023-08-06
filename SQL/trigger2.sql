CREATE OR REPLACE FUNCTION check_dipartimento()
RETURNS TRIGGER LANGUAGE plpgsql AS
$$
    DECLARE
        n INTEGER;

    BEGIN
        SELECT COUNT(*) INTO n
        FROM Dipendente
        WHERE Dipendente.dipartimento = OLD .dipartimento;

        IF n <= 1 THEN 
            RAISE NOTICE 'Non è possibile eliminare il dipendente';
            RETURN NULL;
        END IF;

        RETURN OLD;

    END;
$$;

CREATE TRIGGER check_dipartimento
BEFORE UPDATE OR DELETE ON Dipendente
FOR EACH ROW EXECUTE PROCEDURE check_dipartimento();