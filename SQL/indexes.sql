CREATE INDEX index_matricola_competenza_in_possiede ON Possiede (matricola, competenza);
CREATE INDEX index_matricola_in_dipendente ON Dipendente (matricola);