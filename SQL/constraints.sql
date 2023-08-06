alter table dipendente 
add constraint check_laurea
check ((data_laurea is null) = (classe_laurea is null));

alter table dipendente 
add constraint check_dottorato
check ((data_dottorato is null) = (classe_dottorato is null));

alter table dipendente 
add constraint check_laurea_dottorato
check (check_qualifica(classe_laurea, classe_dottorato));