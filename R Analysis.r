############################
# Installation Libraries
install.packages("RPostgreSQL")
install.packages("tidyverse")
install.packages("stringr")
install.packages("dplyr")

# Include libraries
require("RPostgreSQL")
require("tidyverse")
require("stringr")
require("dplyr")
require("ggplot2")
############################

############################
# Connection to DB

# create a connection
# save the password that we can "hide" it as best as we can by collapsing it

pw <- {
  "postgres"
}

# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "ateneo",
                 host = "localhost", port = 5433,
                 user = "postgres", password = pw)


# Delete password
rm(pw)

###########################
# Utils variable
names_vector <- readLines("data/nomi.txt")
surnames_vector <- readLines("data/cognomi.txt")
country_vector <- readLines("data/province.txt")
address_vector <- readLines("data/via.txt")
alphabet <- c('A', 'B', 'C', 'D', 'E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z')
faculties_denomination <- c("Facolta di Psicologia", "Facolta di Matematica", "Facolta di Medicina", "Facolta di Ingeneria", "Facolta di Giurisprudenza")
degree_courses_vector <- readLines("data/corsi_di_laurea.txt")
duration_type=c("Magistrale", "Triennale")
teacher_role <- c('Attivo', 'In Aspettativa', 'Fuori Ruolo')
phone_prefix <- readLines("data/prefissi_telefonici.txt")

###########################
# Students table population
student_df <- data.frame(
  matricola = sample(1:5001, 5000, replace=F),
  nome=sample(names_vector, 5000, replace=T),
  cognome=sample(surnames_vector, 5000, replace=T),
  data_di_nascita=sample(seq(as.Date('1972/01/01'), as.Date('2002/12/31'), by="day"), 5000, replace=T),
  via=sample(address_vector, 5000, replace = T),
  citta=sample(country_vector, 5000, replace=T),
  nazione=sample("Italia", 5000, replace=T),
  civico=sample(1:120, 5000, replace=T),
  provincia=sample(country_vector, 5000, replace=T),
  cap=sample(30000:75000, 5000, replace=T),
  cf=sample("", 5000, replace=T)
)

## Fiscal Code Generator
# 3 Lettere nome
# 3 Lettere cognome
# Anno di nascita
# Carattere
# Due Cifre
# Carattere
# 3 Cifre
# Carattere

for (row in 1:nrow(student_df)){
  nm <- substr(student_df[row, 'nome'], 1, 3)
  cgnm <- substr(student_df[row, 'cognome'], 1, 3)
  dt <- substr(format(student_df[row, 'data_di_nascita'], "%Y"), 3,4)
  ch1 <- sample(alphabet,1)
  ch2 <- sample(10:99, 1)
  ch3 <- sample(alphabet, 1)
  ch4 <- sample(100:999, 1)
  ch5 <- sample(alphabet, 1)
  cf <- toupper(paste(nm,cgnm,dt,ch1,ch2,ch3,ch4,ch5, sep=""))
  student_df[row, 'cf'] = cf
}

write.csv(student_df,"students.csv", row.names = FALSE)
dbWriteTable(con, name=c("public","studente"), value=student_df, append=T, row.names=F)


###########################
# Faculties table population

faculties_df <- data.frame(
  denominazione = sample(faculties_denomination, 5, replace=F),
  indirizzo = ""
)

for(row in 1:nrow(faculties_df)){
  indirizzo = paste(sample(address_vector, 1),
                           sample(1:120,1),
                           sample(33010:33050, 1),
                           'Udine',
                           'Italia')
  faculties_df[row, 'indirizzo'] = indirizzo
}


dbWriteTable(con, name=c("public","facolta"), value=faculties_df, append=T, row.names=F)
write.csv(faculties_df,"faculties.csv", row.names = TRUE)

###########################
# Degree_courses table population
# PROBLEM: Not all faculties has been used

degree_courses_df <- data.frame(
  nome = sample(degree_courses_vector, 30, replace=F),
  durata = sample(duration_type, 30, replace = T),
  numero_studenti_iscritti = 0
)


for (row in 1:nrow(degree_courses_df))
{
  random_faculty = faculties_df[sample(nrow(faculties_df), 1), ]
  degree_courses_df[row, 'facolta_denominazione'] = random_faculty['denominazione']
  degree_courses_df[row, 'facolta_indirizzo'] = random_faculty['indirizzo']
}


dbWriteTable(con, name=c("public","corso_di_laurea"), value=degree_courses_df, append=T, row.names=F)
write.csv(degree_courses_df[, c(1, 4,5,2, 3)],"degree_courses.csv", row.names = FALSE)

###########################
# Courses table population

courses_vector <- readLines("data/corso.txt")

courses_df <- data.frame(
  codice = sample(1:600, 600),
  nome = sample(courses_vector, 600, replace=T)
)

for (row in 1:nrow(courses_df))
{
  random_faculty = faculties_df[sample(nrow(faculties_df), 1), ]
  courses_df[row, 'facolta_denominazione'] = random_faculty['denominazione']
  courses_df[row, 'facolta_indirizzo'] = random_faculty['indirizzo']
}


dbWriteTable(con, name=c("public","corso"), value=courses_df, append=T, row.names=F)
write.csv(courses_df,"courses.csv", row.names = FALSE)

###############################
# Relation Course Faculty population

eroga_df <- data.frame()

for (row in 1:nrow(courses_df)){
  # Choose random degree course
  random_degree_course = sample_n(degree_courses_df,1)
  eroga_df[row, 'codice_corso'] = as.integer(courses_df[row, "codice"])
  eroga_df[row, 'facolta_denominazione_corso'] = courses_df[row, "facolta_denominazione"]
  eroga_df[row, 'facolta_indirizzo_corso'] = courses_df[row, "facolta_indirizzo"]
  eroga_df[row, 'nome_corso_di_laurea'] = random_degree_course["nome"]
  eroga_df[row, 'facolta_denominazione_corso_di_laurea'] = random_degree_course["facolta_denominazione"]
  eroga_df[row, 'facolta_indirizzo_corso_di_laurea'] = random_degree_course["facolta_indirizzo"]
  if (random_degree_course["durata"] == "Magistrale"){
    eroga_df[row, 'anno'] = sample(4:5, 1, replace=T)
  } 
  if (random_degree_course["durata"] == "Triennale") {
    eroga_df[row, 'anno'] = sample(1:3, 1, replace=T)
  }
}

dbWriteTable(con, name=c("public","eroga"), value=eroga_df, append=T, row.names=F)
write.csv(eroga_df,"eroga.csv", row.names = FALSE)



##########################
# Teachers table population

teacher_df <- data.frame(
  nome = sample(names_vector, 450, replace = T),
  cognome = sample(surnames_vector, 450, replace = T),
  ruolo = sample(teacher_role, 450, replace=T),
  #telefono_prefisso = sample(phone_prefix, 450, replace=T),
  #telefono_suffisso = sample(1000000:9999999, 450, replace=F),
  cf = sample("", 450, replace=T)
)

for(row in 1:nrow(teacher_df)){
  nm <- substr(teacher_df[row, 'nome'], 1, 3)
  cgnm <- substr(teacher_df[row, 'cognome'], 1, 3)
  dt <- sample(64:89, 1)
  ch1 <- sample(alphabet,1)
  ch2 <- sample(10:99, 1)
  ch3 <- sample(alphabet, 1)
  ch4 <- sample(100:999, 1)
  ch5 <- sample(alphabet, 1)
  cf <- toupper(paste(nm,cgnm,dt,ch1,ch2,ch3,ch4,ch5, sep=""))
  teacher_df[row, 'cf'] = cf
  
  if(teacher_df[row, 'ruolo'] == 'In Aspettativa' || (teacher_df[row, 'ruolo'] == 'Fuori Ruolo')){
    teacher_df[row, 'data_sospensione'] = sample(seq(as.Date('2022/01/01'), as.Date('2022/01/17'), by="day"),1) 
  }

}

dbWriteTable(con, name=c("public","docente"), value=teacher_df, append=T, row.names=F)
write.csv(teacher_df[, c(4,1,2,3,5)],"teachers.csv", row.names = FALSE)


#######################################
# Student degree courses relation population
student_degree_courses_df <- data.frame()

for(row in 1:nrow(student_df))
{
  random_degree_course = sample_n(degree_courses_df,1)
  student_degree_courses_df[row, 'studente_matricola'] = student_df[row, 'matricola']
  student_degree_courses_df[row, 'nome_corso_di_laurea'] = random_degree_course['nome']
  student_degree_courses_df[row, 'facolta_denominazione'] = random_degree_course['facolta_denominazione']
  student_degree_courses_df[row, 'facolta_indirizzo'] = random_degree_course['facolta_indirizzo']
  
}

dbWriteTable(con, name=c("public","e_iscritto"), value=teacher_df, append=T, row.names=F)
write.csv(student_degree_courses_df,"iscrizioni.csv", row.names = FALSE)

###################################
# Teacher phone population
teachers_phone <- data.frame(
  prefisso = sample(phone_prefix, 450, replace=T),
  suffisso = sample(1000000:9999999, 450, replace=F),
  docente_cf = sample(teacher_df$cf, 450, replace = T)
)


dbWriteTable(con, name=c("public","recapito_telefono_docente"), value=teachers_phone, append=T, row.names=F)
write.csv(teachers_phone,"teachers_phones.csv", row.names = FALSE)


##########################
# Teachers_courses relation population

# Select active teachers 
active_teachers <- teacher_df[teacher_df$ruolo == 'Attivo',]

teacher_courses_df <- data.frame()

for (row in 1:nrow(courses_df))
{
  random_teacher = active_teachers[sample(nrow(active_teachers), 1), ]
  teacher_courses_df[row, 'cf_docente'] <-random_teacher['cf']
  teacher_courses_df[row, 'codice_corso'] <- courses_df[row, 'codice']
  teacher_courses_df[row, 'facolta_denominazione'] <- courses_df[row, 'facolta_denominazione']
  teacher_courses_df[row, 'facolta_indirizzo'] <- courses_df[row, 'facolta_indirizzo']
  teacher_courses_df[row, 'anno'] <- "2020-2021"
}

dbWriteTable(con, name=c("public","tiene"), value=teacher_courses_df, append=T, row.names=F)
write.csv(teacher_courses_df,"teacher_courses.csv", row.names = FALSE)

##########################
# Exam relation population
exam_df <- data.frame()

exam_students <- c()
exam_courses_code <- c()
exam_faculty_denomination <- c()
exam_faculty_address <- c()
exam_vote <- c()
exam_laude <- c()
exam_accepted <- c()
exam_date <- c()




# Per ciascun corso
for (row in 1:nrow(courses_df))
{
  courses_code = courses_df[row, 'codice']
  courses_faculty_denomination = courses_df[row, 'facolta_denominazione']
  courses_faculty_address = courses_df[row, 'facolta_indirizzo']
  
  print(paste("ELABORO ", courses_code))
  # Tutti gli studenti che frequentano quel corso
  tmp_students <- dbGetQuery(con, paste("SELECT studente_matricola
                   FROM frequenta
                   WHERE codice_corso = ", courses_code))
  
  for(student_list in tmp_students['studente_matricola']){
    for (student in student_list){
      for (time in 1:sample(0:2, 1)){
        exam_students <- append(exam_students, student) 
        exam_courses_code <- append(exam_courses_code, courses_code) 
        exam_faculty_address <- append(exam_faculty_address, courses_faculty_address)
        exam_faculty_denomination <- append(exam_faculty_denomination, courses_faculty_denomination)
        exam_vote <- append(exam_vote, sample(14:30, 1))
        exam_date <- append(exam_date, sample(seq(as.Date('2021/01/01'), as.Date('2022/02/01'), by="day"),1))
      }
    }
  }
}

#print(exam_students)
#print(exam_courses_code)
exam_df <- data.frame(
  studente_matricola = exam_students,
  codice_corso = exam_courses_code,
  facolta_denominazione = exam_faculty_denomination,
  facolta_indirizzo = exam_faculty_address,
  voto = exam_vote,
  data_esame = exam_date
  #accettato = sample(NA, nrow(exam_students), replace=TRUE)
  #lode = sample(NA, nrow(exam_students), replace=TRUE)
)


exam_df <- exam_df[!duplicated(exam_df[c('studente_matricola', 'codice_corso',
                                         'facolta_denominazione', 'facolta_indirizzo',
                                         'data_esame')]), ]

last_exam_tmp <- exam_df %>%
  group_by(studente_matricola, codice_corso) %>%
  filter(data_esame == max(data_esame) &
           voto >= 18)
  

for(row in 1:nrow(exam_df)){
  if(exam_df[row, 'voto'] >= 18){
    exam_df[row, 'accettato'] = FALSE
  }
  else{
    exam_df[row, 'accettato'] = NA
  }
  if(exam_df[row, 'voto'] == 30){
    if(sample(0:1, 1) == 1){
      exam_df[row, 'lode'] = TRUE   
    }
    else{
      exam_df[row, 'lode'] = FALSE   
    }
  }
  
}



last_exam_tmp[, 'accettato']= sample(c(TRUE, FALSE), nrow(last_exam_tmp), replace=TRUE)

# Joining the dataframe
# First anti join to remove all useless in exam_df
test_exam_df <- anti_join(
  exam_df,
  last_exam_tmp,
  by = c("studente_matricola", "codice_corso", 
         "facolta_denominazione", "facolta_indirizzo", 
         "data_esame")
)

# Now full join
test_exam_df <- full_join(
  test_exam_df,
  last_exam_tmp,
  by = c("studente_matricola", "codice_corso", 
         "facolta_denominazione", "facolta_indirizzo", 
         "data_esame")
) 

test_exam_df <- test_exam_df %>% 
  mutate(voto = coalesce(voto.x, voto.y)) %>%
  mutate(accettato = coalesce(accettato.x, accettato.y)) %>%
  mutate(lode = coalesce(lode.x, lode.y)) %>%
  select(studente_matricola, codice_corso, facolta_denominazione, 
         facolta_indirizzo, data_esame, voto, lode, accettato)

dbWriteTable(con, name=c("public","esame"), value=test_exam_df, append=T, row.names=F)
write.csv(test_exam_df,"exams.csv", row.names = FALSE)



# Analysis
# Ratio between esami fatti ed esami non passati
exam_ratio <- dbGetQuery(con, "select corso.nome, tentativi_esame.codice_corso, tentativi_esame.facolta_denominazione,
       tentativi_esame.facolta_indirizzo, tentativi_esame.num as esami_fatti,
       esami_non_passati.num as esami_non_passati,
       esami_non_passati.num*1.0/ tentativi_esame.num*1.0 as ratio
from tentativi_esame, esami_non_passati, corso
where tentativi_esame.codice_corso = esami_non_passati.codice_corso and
      tentativi_esame.facolta_denominazione = esami_non_passati.facolta_denominazione and
      tentativi_esame.facolta_indirizzo = esami_non_passati.facolta_indirizzo and
      corso.codice = tentativi_esame.codice_corso and
      corso.facolta_denominazione = tentativi_esame.facolta_denominazione and
      corso.facolta_indirizzo = tentativi_esame.facolta_indirizzo
order by ratio desc
limit 3")

exam_ratio_2 <- dbGetQuery(con, "select corso.nome, tentativi_esame.codice_corso, tentativi_esame.facolta_denominazione,
       tentativi_esame.facolta_indirizzo, tentativi_esame.num as esami_fatti,
       esami_non_passati.num as esami_non_passati,
       esami_non_passati.num*1.0/ tentativi_esame.num*1.0 as ratio
from tentativi_esame, esami_non_passati, corso
where tentativi_esame.codice_corso = esami_non_passati.codice_corso and
      tentativi_esame.facolta_denominazione = esami_non_passati.facolta_denominazione and
      tentativi_esame.facolta_indirizzo = esami_non_passati.facolta_indirizzo and
      corso.codice = tentativi_esame.codice_corso and
      corso.facolta_denominazione = tentativi_esame.facolta_denominazione and
      corso.facolta_indirizzo = tentativi_esame.facolta_indirizzo
order by ratio asc
limit 3")

exam_ratio <- rbind(exam_ratio,exam_ratio_2)

ggplot(exam_ratio, aes(paste(codice_corso, " ", nome, " ", facolta_denominazione), y=ratio, colour=paste(nome, codice_corso, facolta_denominazione), labels=FALSE)) +
  geom_bar(stat="identity")+
  labs(color="Corso \n", y="Esami Fatti / Esami Non Passati", x="Corso") +
  theme(axis.text.x = element_blank()) 


# Exam per monts in 2021

exam_per_month <- dbGetQuery(con, "select date_part('month', data_esame) as mese, count(*) as n_esami
           from esame
           where date_part('year', data_esame) = 2021
           group by date_part('month', data_esame)
           order by date_part('month', data_esame)")

month=c("Gennaio", "Febbraio", "Marzo", "Aprile", "Maggio", "Giugno", "Luglio", "Agosto", "Settembre", "Ottobre", "Novembre", "Dicembre")
ggplot(exam_per_month, aes(x=mese, y=n_esami), group(1)) + 
  geom_line(linetype='dashed')+
  theme(axis.text.x = element_blank()) +
  geom_point()


# Facolta?
faculties_students <- dbGetQuery(con, "select facolta_denominazione, facolta_indirizzo, count(*) as n_studenti
from e_iscritto
group by facolta_denominazione, facolta_indirizzo")

faculties_students <- faculties_students %>% 
  arrange(desc(facolta_denominazione, facolta_indirizzo)) %>%
  mutate(prop = n_studenti / sum(faculties_students$n_studenti) *100) %>%
  mutate(ypos = cumsum(prop)- 0.5*prop )

ggplot(faculties_students, 
       aes(x="", y=prop, fill=paste(facolta_denominazione,facolta_indirizzo))) +
  geom_bar(stat="identity", width=1, color="white") +
  coord_polar("y", start=0) + 
  theme_void() +
  theme(legend.position = "none") + 
  geom_text(aes(y=ypos, label=paste(facolta_denominazione)), color="white", size=3)+
  scale_fill_brewer(palette="Set1")





