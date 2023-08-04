require("RPostgreSQL")
require("tidyverse")
require("stringr")
require("dplyr")
require("ggplot2")
require("lubridate")
require("modelr")

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, dbname = "progetto_basi",
                 host = "localhost", port = 5432,
                 user = "postgres", password = "postgres")

# 1

dipendenti = dbGetQuery(con, "select dipendente.matricola, classe_laurea, classe_dottorato, count(possiede.competenza) as numero_competenze
from dipendente inner join possiede on dipendente.matricola = possiede.matricola 
group by dipendente.matricola;"
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



#2

dipartimenti = dbGetQuery(con, "select nome, numero_afferenti
from dipartimento order by numero_afferenti desc limit 13;")

dipartimenti %>%
    ggplot(aes(x = reorder(nome, -numero_afferenti), y = numero_afferenti)) +
    geom_col(show.legend = FALSE, fill="aquamarine3") + 
    labs(title = "Numero afferenti per dipartimento", x = "Dipartimento", y = "Numero Afferenti")


#3

fornitori = dbGetQuery(con, "select fornitore, count(*) as num from fornisce group by fornitore order by num desc limit 15;")

fornitori = tibble(fornitori)

fornitori %>%
    ggplot(aes(x = reorder(fornitore, -num), y = num)) +
    geom_bar(stat = "identity", fill = "aquamarine3") + 
    labs(title = "Numero dipartimenti per fornitore", x = "Fornitore", y = "Numero Dipartimenti") + 
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


#4

dipendenti_età = dbGetQuery(con, "select dipendente.matricola, progetto, data_di_nascita, progetto.budget 
from coinvolge inner join dipendente on dipendente.matricola = coinvolge.matricola inner join progetto on progetto.codice_aziendale = coinvolge.progetto;
")

dipendenti_età = tibble(dipendenti_età)


birth_date <- as.Date("1973-01-01")
now = Sys.Date()

collocate = function(budget) {
    case_when(
        budget < 10000 ~ 1,
        budget < 20000 ~ 2,
        budget < 30000 ~ 3,
        budget < 40000 ~ 4,
        TRUE ~ 5
    )
}

dipendenti_età %>%
    mutate(age = trunc((data_di_nascita %--% now) /years(1))) %>%
    ggplot() + 
    geom_histogram(aes(x = age))

dipendenti_età %>%
    mutate(age = trunc((data_di_nascita %--% now) /years(1))) %>%
    mutate(fascia_progetto = collocate(budget)) %>%
    group_by(fascia_progetto) %>%
    summarise(eta_media = mean(age)) %>%
    arrange(desc(eta_media)) %>%
    top_n(10) %>%
    ggplot(aes(x = reorder(fascia_progetto, fascia_progetto), y = eta_media)) + 
    geom_col(fill="red") + 
    labs(title = "Età media per fascia progetto", x = "Fascia Progetto", y = "Età media") + 
    theme_bw()



#5

num_budget = dbGetQuery(con, "select progetto, count(*) as num_dip, budget 
from coinvolge inner join progetto on coinvolge.progetto = progetto.codice_aziendale
 group by progetto, budget;")

num_budget = tibble(num_budget)

num_budget %>%
    ggplot(aes(x = num_dip, y = budget)) +
    geom_point()

model = lm(data = num_budget, budget ~ num_dip)

correlation = cor(num_budget$num_dip, num_budget$budget)

num_budget = add_predictions(num_budget, model)

num_budget %>%
    ggplot() +
    geom_point(aes(x = num_dip, y = budget))  + 
    geom_line(aes(x = num_dip, y= pred))
