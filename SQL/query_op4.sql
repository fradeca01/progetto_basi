CREATE OR REPLACE FUNCTION numeroDipendentiAfferenti(dip VARCHAR(100))
RETURNS INT LANGUAGE plpgsql AS
$$ 
DECLARE numDipe INT; 

BEGIN

    IF dip NOT IN (SELECT nome FROM Dipartimento) THEN
        RAISE NOTICE 'Dipartimento % non presente nel database', dip;
    END IF;

    SELECT  numero_afferenti INTO numDipe
    FROM Dipartimento
    WHERE nome = dip;

    RETURN numDipe; 

END;
$$;