select progetto, count(*) as num_dip, budget 
from coinvolge inner join progetto on coinvolge.progetto = progetto.codice_aziendale
group by progetto, budget;