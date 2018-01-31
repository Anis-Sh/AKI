-- pour KDIGO
-- chaque jour : 
	-- creat maximale
	-- débit de diurese sur les 24 heures
	-- eer ?

set search_path to mimiciii;

drop table if exists public.kentran_8_1_table_creat; 
create table public.kentran_8_1_table_creat as 
(
select 	icustay_id
	, max(table_creat.creat) as creat
	, table_creat.day
from (
	select icustay_id
		, (creat.creat)*88 as creat --conversion en micromol/L
		, case
			when (creat.date_creat-creat.admittime) <= '24:00:00' then 1
			when (creat.date_creat-creat.admittime) between '24:00:01' and '48:00:00'  then 2
			when (creat.date_creat-creat.admittime) between '48:00:01' and '72:00:00' then 3
			when (creat.date_creat-creat.admittime) between '72:00:01' and '96:00:00'  then 4
			when (creat.date_creat-creat.admittime) between '96:00:01' and '120:00:00' then 5
			when (creat.date_creat-creat.admittime) between '120:00:01' and '144:00:00' then 6
			when (creat.date_creat-creat.admittime) between '144:00:01' and '168:00:00' then 7
			else null
		end as day
	from(
		select demo.icustay_id
			, demo.admittime
			, lab.valuenum as creat
			, lab.charttime as date_creat
		from labevents lab
		, public.kentran_1_3_demographics_nockd demo
		where	lab.itemid in(50912, 51081) and
			demo.subject_id=lab.subject_id
		) as creat
	) table_creat
where 	day is not null
group by icustay_id, day
order by icustay_id, day	
);

Select * from public.kentran_8_1_table_creat;