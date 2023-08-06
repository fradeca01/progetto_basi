ALTER TABLE Dipendente
ADD CONSTRAINT check_laurea 
CHECK ((data_laurea IS NULL) = (classe_laurea IS NULL));

ALTER TABLE Dipendente
ADD CONSTRAINT check_dottorato 
CHECK ((data_dottorato IS NULL) = (classe_dottorato IS NULL));

ALTER TABLE Dipendente
ADD CONSTRAINT check_laurea_dottorato
CHECK (check_qualifica(classe_laurea, classe_dottorato));