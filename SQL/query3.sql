select fornitore, count(*) as num 
from fornisce 
group by fornitore 
order by num desc limit 15;