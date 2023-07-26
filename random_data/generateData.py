import pandas as pd
from faker import Faker
from collections import defaultdict
from sqlalchemy import create_engine
import psycopg2
import random 
import datetime
from pprint import pprint
import random

fake = Faker('it-IT')

NUM_FORNITORI = 1000
NUM_DIPENDENTI = 10000
NUM_MATRIMONI = 1000
NUM_PROGETTI = 5000
NUM_COMPETENZE_DIP = 10
NUM_DIP_PROGETTO = 5

FILE_DIPARTIMENTO = "MOCK_DEPARTMENT.txt"
FILE_QUALIFICHE = "MOCK_QUALIFY.txt"
FILE_SKILLS = "MOCK_SKILLS.txt"
FILE_LAUREE = "MOCK_DEGREES.txt"
FILE_DOTTORATI = "MOCK_PHDS.txt"

#FORNITORE
fornitore = defaultdict(list)
for _ in range(NUM_FORNITORI):
    fornitore["nome"].append(fake.company())
    fornitore["indirizzo"].append(fake.address())

df_fornitore = pd.DataFrame(fornitore)
df_fornitore.drop_duplicates(inplace=True, subset="nome")

print("Created Fornitore")



#DIPARTIMENTO

dipartimento = defaultdict(list)

f = open(FILE_DIPARTIMENTO)
lines = f.read().splitlines()
f.close()

dipartimento["recapito"] = (fake.random_sample(elements = range(100000,999999), length = len(lines)))

for i in range(len(lines)):
    dipartimento["recapito"][i] = int("0432" + str(dipartimento["recapito"][i]))

for line in lines:
    dipartimento["nome"].append(line)
    dipartimento["email"].append(line.replace(" ","").lower() + "@company.com")
    dipartimento["ultimo_acquisto"].append(random.choice(fornitore["nome"]))
    dipartimento["data_ultimo_acquisto"].append(fake.date_between(start_date = datetime.date(2021,1,1)))

#Numero afferenti viene aggiunto dopo

print("Created Dipartimento")

df_dipartimento = pd.DataFrame(dipartimento)



#FORNISCE

fornisce = defaultdict(list)

for _ in range(400):
    i = random.randint(0,len(dipartimento["nome"])-1)
    p = random.randint(0,9)
    fornisce["dipartimento"].append(dipartimento["nome"][i])
    if p < 9:
        fornisce["fornitore"].append(dipartimento["ultimo_acquisto"][i])
    else:
        fornisce["fornitore"].append(fake.random_element(fornitore["nome"]))


print("Created Fornisce")

df_fornisce = pd.DataFrame(fornisce)






#DIPENDENTE

dipendente = defaultdict(list)

dipendente["matricola"] = fake.random_sample(elements = range(1, 1000000), length = NUM_DIPENDENTI)

f = open(FILE_QUALIFICHE)
qualifies = f.read().splitlines()
f.close()

f = open(FILE_LAUREE)
degrees = f.read().splitlines()
f.close()

f = open(FILE_DOTTORATI)
phds = f.read().splitlines()
f.close()




for _ in range(NUM_DIPENDENTI):
    dipendente["nome"].append(fake.first_name())
    dipendente["cognome"].append(fake.last_name())
    dipendente["qualifica"].append(fake.random_element(elements=qualifies))
    dipendente["dipartimento"].append(fake.random_element(elements=dipartimento["nome"]))
    dipendente["data_assunzione"].append(fake.date_time_between(start_date = datetime.date(2015, 1, 1)))

    nascita = fake.date_time_between(end_date = datetime.date(2003, 1, 1))
    dipendente["data_di_nascita"].append(nascita)

    p_laureato = random.randint(0,9)
    if p_laureato < 5:
        dipendente["classe_laurea"].append(fake.random_element(elements = degrees))
        dipendente["data_laurea"].append(fake.date_time_between(start_date = nascita + datetime.timedelta(days = 20*365)))

        p_dottorato = random.randint(0,9)
        if p_dottorato < 2:
            dipendente["classe_dottorato"].append(fake.random_element(elements = phds))
            dipendente["data_dottorato"].append(fake.date_time_between(start_date = nascita + datetime.timedelta(days = 28*365)))
        else:
            dipendente["classe_dottorato"].append("")
            dipendente["data_dottorato"].append(None)
    else:
        dipendente["classe_laurea"].append("")
        dipendente["data_laurea"].append(None)
        dipendente["classe_dottorato"].append("")
        dipendente["data_dottorato"].append(None)


df_dipendente = pd.DataFrame(dipendente)

print("Created Dipendente")

pprint(df_dipendente)

df_dipartimento.insert(2, "numero_afferenti", 0)

df_dipartimento.set_index("nome", inplace=True)

for i in range(len(df_dipendente.index)):
    dip = df_dipendente.iloc[[i]]["dipartimento"].to_string(index = False)
    df_dipartimento.loc[df_dipartimento["nome"] == dip, "numero_afferenti"] +=  1

pprint(len(df_dipendente.index))
pprint(df_dipendente)
pprint(df_dipartimento)

pprint(df_dipartimento["numero_afferenti"].sum())
'''
#Matrimonio

matrimonio = defaultdict(list)

coniugi = fake.random_sample(elements = dipendente["matricola"], length = NUM_MATRIMONI*2)

for i in range(NUM_MATRIMONI):
    matrimonio["coniuge1"].append(coniugi[2*i])
    matrimonio["coniuge2"].append(coniugi[2*i+1])

print("Created Matrimonio")


#PROGETTO

progetto = defaultdict(list)

progetto["codice_aziendale"] = fake.random_sample(elements = range(1000000), length = NUM_PROGETTI)
progetto["budget"] = fake.random_elements(elements = range(200, 5000), unique = False, length = NUM_PROGETTI)
print("Created Progetto")

#COMPETENZA

competenza = defaultdict(list)


f = open(FILE_SKILLS)
skills = f.read().splitlines()
f.close()

competenza["nome"] = skills

print("Created Competenza")

#POSSIEDE

possiede = defaultdict(list)

def add_possiede(i):
    possiede["competenza"].append(fake.random_element(competenza["nome"])) 
    possiede["matricola"].append(fake.random_element(dipendente["matricola"]))    
    if(i % 10000 == 0):
        print(i)


for i in range(NUM_COMPETENZE_DIP*NUM_DIPENDENTI):
    add_possiede(i)



df_possiede = pd.DataFrame(possiede)
df_possiede.drop_duplicates(inplace = True)


print("Created Possiede")

#COINVOLGE

coinvolge = defaultdict(list)

for p in progetto["codice_aziendale"]:
    matr = fake.random_sample(dipendente["matricola"], length = NUM_DIP_PROGETTO)
    for i in range(NUM_DIP_PROGETTO):
        competenze  = df_possiede.loc[df_possiede['matricola'] == matr[i]]["competenza"].tolist()
        if(competenze != []):
            coinvolge["matricola"].append(matr[i])
            coinvolge["competenza"].append(fake.random_element(competenze))
            coinvolge["progetto"].append(p)
        #coinvolge["competenza"].append(fake.random_element(posssiede))
        
print("Created Coinvolge")

df_dipartimento = pd.DataFrame(dipartimento)
df_matrimonio = pd.DataFrame(matrimonio)
df_progetto = pd.DataFrame(progetto)
df_competenza = pd.DataFrame(competenza)
df_coinvolge = pd.DataFrame(coinvolge)

engine = create_engine("postgresql+psycopg2://postgres:postgres@/progetto_basi")


df_fornitore.to_sql('fornitore', con=engine, index=False, if_exists='append')
df_dipartimento.to_sql('dipartimento', con=engine, index=False, if_exists='append')
df_fornisce.to_sql('fornisce', con=engine, index=False, if_exists='append')
df_dipendente.to_sql('dipendente', con=engine, index=False, if_exists='append')
df_matrimonio.to_sql('matrimonio', con=engine, index=False, if_exists='append')
df_progetto.to_sql('progetto', con=engine, index=False, if_exists='append')
df_competenza.to_sql('competenza', con=engine, index=False, if_exists='append')
df_possiede.to_sql('possiede', con=engine, index=False, if_exists='append')
df_coinvolge.to_sql('coinvolge', con=engine, index=False, if_exists='append')
'''