CREATE OR REPLACE FUNCTION check_qualifica(el1 VARCHAR(100), el2 VARCHAR(100))
RETURNS BOOLEAN LANGUAGE plpgsql AS 
$$ 
    BEGIN
        IF (el2 IS NOT NULL) THEN 
            RETURN (el1 IS NOT NULL);
        ELSE
            RETURN TRUE;
        END IF;
    END
$$;