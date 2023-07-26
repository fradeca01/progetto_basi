require("RPostgreSQL")
require("tidyverse")
require("stringr")
require("dplyr")
require("ggplot2")



drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "progetto_basi",
                 host = "localhost", port = 5432,
                 user = "postgres", password = "postgres")

#dipendenti = dbGetQuery(con, "select * from dipartimento")

#print(dipendenti)

# La correlazione tra i dipendenti laureati con o senza dottorato e il numero di competenze
# possedute da tali dipendenti.

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
    summarise(num_medio = sum(numero_competenze) / n()) %>%
    ggplot(aes(x = classe_laurea, y = num_medio)) + 
    geom_bar(stat = "identity")


dipartimenti = dbGetQuery(con, "select nome, numero_afferenti
from dipartimento order by numero_afferenti desc limit 10;")

dipartimenti %>%
    ggplot(aes(x = nome, y = numero_afferenti)) +
    geom_bar(stat = "identity")




