-- pour KDIGO
-- chaque jour : 
	-- creat maximale
	-- débit de diurese sur les 24 heures
	-- eer ?

set search_path to mimiciii;

drop table if exists public.kentran_8_3_table_rrt; 
create table public.kentran_8_3_table_rrt as 


(
select 	icustay_id
	, max(table_rrt.rrt) as rrt
	, table_rrt.day as day
from (
	select icustay_id
		, rrt.rrt as rrt --conversion en micromol/L
		, case
			when (rrt.date_rrt-rrt.admittime) <= '24:00:00' then 1
			when (rrt.date_rrt-rrt.admittime) between '24:00:01' and '48:00:00'  then 2
			when (rrt.date_rrt-rrt.admittime) between '48:00:01' and '72:00:00' then 3
			when (rrt.date_rrt-rrt.admittime) between '72:00:01' and '96:00:00'  then 4
			when (rrt.date_rrt-rrt.admittime) between '96:00:01' and '120:00:00' then 5
			when (rrt.date_rrt-rrt.admittime) between '120:00:01' and '144:00:00' then 6
			when (rrt.date_rrt-rrt.admittime) between '144:00:01' and '168:00:00' then 7
			else null
		end as day
	from(
		select demo.icustay_id
			, demo.admittime
			,case
				when ce.itemid in (152,148,149,146,147,151,150) and value is not null then 1
				when ce.itemid in (229,235,241,247,253,259,265,271) and value = 'Dialysis Line' then 1
				when ce.itemid = 582 and value in ('CAVH Start','CAVH D/C','CVVHD Start','CVVHD D/C','Hemodialysis st','Hemodialysis end') then 1
				else 0 end as rrt
			, ce.charttime as date_rrt
		from chartevents ce, public.kentran_1_3_demographics_nockd demo
		where	ce.itemid in( 152 -- "Dialysis Type";61449
					,148 -- "Dialysis Access Site";60335
					,149 -- "Dialysis Access Type";60030
					,146 -- "Dialysate Flow ml/hr";57445
					,147 -- "Dialysate Infusing";56605
					,151 -- "Dialysis Site Appear";37345
					,150 -- "Dialysis Machine";27472
					,229 -- INV Line#1 [Type]
					,235 -- INV Line#2 [Type]
					,241 -- INV Line#3 [Type]
					,247 -- INV Line#4 [Type]
					,253 -- INV Line#5 [Type]
					,259 -- INV Line#6 [Type]
					,265 -- INV Line#7 [Type]
					,271 -- INV Line#8 [Type]
					,582 -- Procedures
					) and
			demo.subject_id=ce.subject_id
		) as rrt
	) table_rrt
where 	day is not null
group by icustay_id, day
order by icustay_id, day	
);

select * from public.kentran_8_3_table_rrt;