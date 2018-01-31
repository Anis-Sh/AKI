drop table if exists public.kentran_1_2_demographics_select;

create table  public.kentran_1_2_demographics_select
as 
(
 select *
 from public.kentran_1_1_demographics as demographics
 where 
	demographics.age >=18 AND
	demographics.first_icu_stay = 'Y' AND
	demographics.admission_type in ('URGENT','EMERGENCY')
order by subject_id, admittime -- Ken: hadm_id does not necessary go in sequence. Changed to sort by admittime
);

select * from public.kentran_1_2_demographics_select
