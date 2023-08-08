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

dipendenti = dipendenti %>% 
    mutate(classe_laurea = replace(classe_laurea, !is.na(classe_laurea) & is.na(classe_dottorato), "laurea_no_dott") ) %>%
    mutate(classe_laurea = replace(classe_laurea, is.na(classe_laurea), "non_laureato")) %>%
    mutate(classe_laurea = replace(classe_laurea, !is.na(classe_dottorato), "dottorato") ) %>%
    mutate(classe_laurea = factor(classe_laurea, levels = c("dottorato", "laurea_no_dott", "non_laureato" ), 
            labels= c("Dottorato", "Solo laureato", "Non laureato"))) %>%
    group_by(classe_laurea) %>%
    summarise(num_medio_competenze = sum(numero_competenze) / n())

dipendenti %>%
    ggplot(aes(x = fct_rev(classe_laurea), y = num_medio_competenze, fill = classe_laurea)) + 
    geom_col(show.legend = FALSE) + 
    ggtitle("Numero medio competenze per dipendente") +
    labs(x = "Classe Laurea", y = "Numero medio competenze") + 
    theme_bw() + 
    theme(axis.text = element_text(size=25),
         axis.title=element_text(size=28),
         plot.title=element_text(size=30, face="bold"),
         axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
         axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))

ggsave("progetto_basi/R/plot1.pdf", dpi=320, height = 15)


#2

dipartimenti = dbGetQuery(con, "select nome, numero_afferenti
from dipartimento order by numero_afferenti desc limit 13;")

dipartimenti %>%
    ggplot(aes(x = reorder(nome, -numero_afferenti), y = numero_afferenti)) +
    geom_col(show.legend = FALSE, fill="darkred") + 
    labs(title = "Numero afferenti per dipartimento", x = "Dipartimento", y = "Numero Afferenti")+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    theme(axis.text = element_text(size=25),
         axis.title=element_text(size=28),
         plot.title=element_text(size=30, face="bold"),
         axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
         axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))


ggsave("progetto_basi/R/plot2.pdf", dpi=320, height = 15)


#3

fornitori = dbGetQuery(con, "select fornitore, count(*) as num from fornisce group by fornitore order by num desc limit 15;")

fornitori = tibble(fornitori)

fornitori %>%
    ggplot(aes(x = reorder(fornitore, -num), y = num)) +
    geom_bar(stat = "identity", fill = "darkgreen") + 
    labs(title = "Numero dipartimenti per fornitore", x = "Fornitore", y = "Numero Dipartimenti") + 
    theme_bw() + 
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
        theme(axis.text = element_text(size=25),
         axis.title=element_text(size=28),
         plot.title=element_text(size=30, face="bold"),
         axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
         axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))


ggsave("progetto_basi/R/plot3.pdf", dpi=320, height = 15)


# #4

# dipendenti_età = dbGetQuery(con, "select dipendente.matricola, progetto, data_di_nascita, progetto.budget 
# from coinvolge inner join dipendente on dipendente.matricola = coinvolge.matricola inner join progetto on progetto.codice_aziendale = coinvolge.progetto;
# ")

# dipendenti_età = tibble(dipendenti_età)


# birth_date <- as.Date("1973-01-01")
# now = Sys.Date()

# collocate = function(budget) {
#     case_when(
#         budget < 10000 ~ 1,
#         budget < 20000 ~ 2,
#         budget < 30000 ~ 3,
#         budget < 40000 ~ 4,
#         TRUE ~ 5
#     )
# }

# dipendenti_età %>%
#     mutate(age = trunc((data_di_nascita %--% now) /years(1))) %>%
#     ggplot() + 
#     geom_histogram(aes(x = age))

# dipendenti_età %>%
#     mutate(age = trunc((data_di_nascita %--% now) /years(1))) %>%
#     mutate(fascia_progetto = collocate(budget)) %>%
#     group_by(fascia_progetto) %>%
#     summarise(eta_media = mean(age)) %>%
#     arrange(desc(eta_media)) %>%
#     top_n(10) %>%
#     ggplot(aes(x = reorder(fascia_progetto, fascia_progetto), y = eta_media)) + 
#     geom_col(fill="red") + 
#     labs(title = "Età media per fascia progetto", x = "Fascia Progetto", y = "Età media") + 
#     theme_bw()



#5

num_budget = dbGetQuery(con, "select progetto, count(*) as num_dip, budget 
from coinvolge inner join progetto on coinvolge.progetto = progetto.codice_aziendale
 group by progetto, budget;")

num_budget = tibble(num_budget)

num_budget %>%
    mutate(num_dip = factor(num_dip)) %>%
    ggplot(aes(x = num_dip, y = budget)) +
    geom_boxplot(color="darkblue") +
    labs(title="Correlazione numeri dipendenti e budget", x = "Numero dipendenti", y = "Budget")+
    theme_bw() +
    theme(axis.text = element_text(size=25),
         axis.title=element_text(size=28),
         plot.title=element_text(size=30, face="bold"),
         axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
         axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)))

ggsave("progetto_basi/R/plot5.pdf", dpi=320, height = 15)


model = lm(data = num_budget, budget ~ num_dip)


summary(model)

num_budget = add_predictions(num_budget, model)

num_budget %>%
    mutate(num_dip = factor(num_dip)) %>%
    ggplot() +
    geom_boxplot(aes(x = num_dip, y = budget), color="darkblue")  + 
    #geom_line(aes(x = num_dip, y= pred), color=alpha("red",0.6), size=2)+
    geom_abline(slope = model$coefficients[2], intercept = model$coefficients[1], color=alpha("darkred",0.6), size=2)+
    labs(title="Correlazione numeri dipendenti e budget", x = "Numero dipendenti", y = "Budget")+
    theme_bw() +
    theme(axis.text = element_text(size=25),
         axis.title=element_text(size=28),
         plot.title=element_text(size=30, face="bold"),
         axis.title.x = element_text(margin = margin(t = 20, r = 0, b = 0, l = 0)),
         axis.title.y = element_text(margin = margin(t = 0, r = 20, b = 0, l = 0)) )

    


ggsave("progetto_basi/R/plot6.pdf",device="pdf", dpi=320, height = 15)
