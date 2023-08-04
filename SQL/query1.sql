select dipendente.matricola, classe_laurea, classe_dottorato, count(possiede.competenza) as numero_competenze
from dipendente natural join possiede
group by dipendente.matricola;