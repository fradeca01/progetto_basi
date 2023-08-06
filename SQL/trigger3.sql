CREATE OR REPLACE FUNCTION check_progetto()
RETURNS TRIGGER LANGUAGE plpgsql AS
$$
    DECLARE
        n INTEGER;
        matr INTEGER;

    BEGIN
        SELECT COUNT(*) INTO n
        FROM
            (
                SELECT progetto, COUNT(*) AS num_dip
                FROM Coinvolge
                WHERE Coinvolge.progetto IN (
                    SELECT progetto
                    FROM Coinvolge
                    WHERE Coinvolge.matricola = OLD.matricola
                )
                GROUP BY Coinvolge.progetto
                HAVING COUNT(*) = 1
            ) AS prog_num;

        IF n >= 1 THEN
            RAISE NOTICE 'Non è possibile eliminare il dipendente poichè è unico dipendente di alcuni progetti';
            RETURN NULL;
        END IF;

        RETURN OLD;
    END;
$$;

CREATE TRIGGER check_progetto 
BEFORE UPDATE OR DELETE ON Dipendente
FOR EACH ROW EXECUTE PROCEDURE check_progetto();