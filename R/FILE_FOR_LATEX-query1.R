dipendenti = dbGetQuery(con, "select dipendente.matricola, classe_laurea, classe_dottorato, count(possiede.competenza) as numero_competenze
from dipendente inner join possiede on dipendente.matricola = possiede.matricola 
group by dipendente.matricola limit 100;"
)
dipendenti = tibble(dipendenti)


dipendenti %>% 
    mutate(classe_laurea = replace(classe_laurea, classe_laurea != "" & classe_dottorato == "", "laureato e non dottorato") ) %>%
    mutate(classe_laurea = replace(classe_laurea, classe_laurea == "", "non_laureato")) %>%
    mutate(classe_laurea = replace(classe_laurea, classe_dottorato != "", "dottorato") ) %>%
    group_by(classe_laurea) %>%
    summarise(num_medio_competenze = sum(numero_competenze) / n()) %>%
    ggplot(aes(x = classe_laurea, y = num_medio_competenze, fill = classe_laurea)) + 
    geom_col(show.legend = FALSE) + 
    ggtitle("Numero medio competenze per dipendente") +
    labs(x = "Classe Laurea", y = "Numero medio competenze") + 
    theme_bw()


