
-- Joining our cohort demographic with ventdurations

set search_path to mimiciii;


drop table if exists public.kentran_2_2_database_ventiles;
create table public.kentran_2_2_database_ventiles as
(
select *
from  public.kentran_1_3_demographics_nockd de
natural join public.kentran_2_1_ventdurations ventdurations 
where ventdurations.ventnum>=1
order by subject_id, admittime 
);

select * from public.kentran_2_2_database_ventiles;
