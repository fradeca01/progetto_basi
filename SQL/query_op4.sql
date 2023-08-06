CREATE OR REPLACE FUNCTION numeroDipendentiAfferenti(dipartimento VARCHAR(100))
RETURNS INT LANGUAGE plpgsql AS
$$ 
DECLARE numDipe INT; 

BEGIN

    IF dipartimento NOT IN (SELECT nome FROM Dipartimento) THEN
        RAISE NOTICE 'Dipartimento % non presente nel database', dipartimento;
    END IF;

    SELECT  numero_afferenti INTO numDipe
    FROM Dipartimento
    WHERE nome = dipartimento;

    RETURN numDipe; 

END;
$$;