SELECT nome, COUNT(DISTINCT progetto)
FROM Competenza, Coinvolge
WHERE competenza = nome
GROUP BY nome;
