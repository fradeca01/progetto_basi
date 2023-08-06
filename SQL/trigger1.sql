CREATE OR REPLACE FUNCTION check_competenza()
RETURN TRIGGER LANGUAGE plpgsql AS
$$
    DECLARE
        matr INTEGER;
        comp VARCHAR(100);
        n INTEGER;

    BEGIN
        matr = NEW.matricola;
        comp = NEW.competenza;

        SELECT COUNT(*) INTO n
        FROM Possiede
        WHERE Possiede.matricola = matr AND Possiede.competenza = comp;

        IF n = 0 THEN 
            RAISE NOTICE 'Dipendente non ha tale Competenza';
            RETURN NULL;
        END IF;

        RETURN NEW;

    END;
$$;

CREATE TRIGGER check_coinvolge
BEFORE INSERT OR UPDATE ON Coinvolge 
FOR EACH ROW EXECUTE PROCEDURE check_competenza();