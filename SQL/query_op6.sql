CREATE OR REPLACE FUNCTION grandiFornitori(n_min_dip INT)
RETURNS TABLE (codice_fornitore VARCHAR(100), numero_dipartimenti BIGINT) LANGUAGE plpgsql AS
$$
BEGIN

	CREATE TEMPORARY VIEW Numero_dipartimenti_riforniti AS
		SELECT nome, COUNT(*) as ndip
		FROM fornitore, fornisce
		WHERE fornitore = nome
		GROUP BY nome;

	RETURN QUERY
		SELECT *
		FROM Numero_dipartimenti_riforniti
		WHERE ndip > n_min_dip;

END;
$$;