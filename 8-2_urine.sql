set search_path to mimiciii;
drop table if exists public.kentran_8_2_table_urine;

with tab1 as
(
select 	icustay_id
		, sum(table_urine.urine) as urine_6h -- volume urinaire par tranche de 6 heures
		, table_urine.day_6h
		, table_urine.day_12h
		, table_urine.day_24h
	from (
		select urine.icustay_id
			, urine.urine
			, urine.weight
			, case
				when (urine.date_urine-urine.admittime) <= '24:00:00' then 1
				when (urine.date_urine-urine.admittime) between '24:00:01' and '48:00:00'  then 2
				when (urine.date_urine-urine.admittime) between '48:00:01' and '72:00:00' then 3
				when (urine.date_urine-urine.admittime) between '72:00:01' and '96:00:00'  then 4
				when (urine.date_urine-urine.admittime) between '96:00:01' and '120:00:00' then 5
				when (urine.date_urine-urine.admittime) between '120:00:01' and '144:00:00' then 6
				when (urine.date_urine-urine.admittime) between '144:00:01' and '168:00:00' then 7
				else null
			end as day_24h
			, case
				when (urine.date_urine-urine.admittime) <= '6:00:00' then 1
				when (urine.date_urine-urine.admittime) between '6:00:01' and '12:00:00'  then 2
				when (urine.date_urine-urine.admittime) between '12:00:01' and '18:00:00' then 3
				when (urine.date_urine-urine.admittime) between '18:00:01' and '24:00:00'  then 4
				when (urine.date_urine-urine.admittime) between '24:00:01' and '30:00:00' then 5
				when (urine.date_urine-urine.admittime) between '30:00:01' and '36:00:00' then 6
				when (urine.date_urine-urine.admittime) between '36:00:01' and '42:00:00' then 7
				when (urine.date_urine-urine.admittime) between '42:00:01' and '48:00:00' then 8
				when (urine.date_urine-urine.admittime) between '48:00:01' and '54:00:00' then 9
				when (urine.date_urine-urine.admittime) between '54:00:01' and '60:00:00' then 10
				when (urine.date_urine-urine.admittime) between '60:00:01' and '66:00:00' then 11
				when (urine.date_urine-urine.admittime) between '66:00:01' and '72:00:00' then 12
				when (urine.date_urine-urine.admittime) between '72:00:01' and '78:00:00' then 13
				when (urine.date_urine-urine.admittime) between '78:00:01' and '84:00:00' then 14
				when (urine.date_urine-urine.admittime) between '84:00:01' and '90:00:00' then 15
				when (urine.date_urine-urine.admittime) between '90:00:01' and '96:00:00' then 16
				when (urine.date_urine-urine.admittime) between '96:00:01' and '102:00:00' then 17
				when (urine.date_urine-urine.admittime) between '102:00:01' and '108:00:00' then 18
				when (urine.date_urine-urine.admittime) between '108:00:01' and '114:00:00' then 19
				when (urine.date_urine-urine.admittime) between '114:00:01' and '120:00:00' then 20
				when (urine.date_urine-urine.admittime) between '120:00:01' and '126:00:00' then 21
				when (urine.date_urine-urine.admittime) between '126:00:01' and '132:00:00' then 22
				when (urine.date_urine-urine.admittime) between '132:00:01' and '138:00:00' then 23
				when (urine.date_urine-urine.admittime) between '138:00:01' and '144:00:00' then 24
				when (urine.date_urine-urine.admittime) between '144:00:01' and '150:00:00' then 25
				when (urine.date_urine-urine.admittime) between '150:00:01' and '156:00:00' then 26
				when (urine.date_urine-urine.admittime) between '156:00:01' and '162:00:00' then 27
				when (urine.date_urine-urine.admittime) between '162:00:01' and '168:00:00' then 28
				else null
			end as day_6h
			, case
				when (urine.date_urine-urine.admittime) <= '12:00:00' then 1
				when (urine.date_urine-urine.admittime) between '12:00:01' and '24:00:00' then 2
				when (urine.date_urine-urine.admittime) between '24:00:01' and '36:00:00' then 3
				when (urine.date_urine-urine.admittime) between '36:00:01' and '48:00:00' then 4
				when (urine.date_urine-urine.admittime) between '48:00:01' and '60:00:00' then 5
				when (urine.date_urine-urine.admittime) between '60:00:01' and '72:00:00' then 6
				when (urine.date_urine-urine.admittime) between '72:00:01' and '84:00:00' then 7
				when (urine.date_urine-urine.admittime) between '84:00:01' and '96:00:00' then 8
				when (urine.date_urine-urine.admittime) between '96:00:01' and '108:00:00' then 9
				when (urine.date_urine-urine.admittime) between '108:00:01' and '120:00:00' then 10
				when (urine.date_urine-urine.admittime) between '120:00:01' and '132:00:00' then 11
				when (urine.date_urine-urine.admittime) between '132:00:01' and '144:00:00' then 12
				when (urine.date_urine-urine.admittime) between '144:00:01' and '156:00:00' then 13
				when (urine.date_urine-urine.admittime) between '156:00:01' and '168:00:00' then 14
				else null
			end as day_12h
		from(
			select demo.icustay_id
				, demo.admittime
				, demo.weight
				, case
					when oe.itemid=227489 then -1*oe.value -- irrigation
					else oe.value
					end as urine
				, oe.charttime as date_urine
			from public.kentran_1_3_demographics_nockd demo, outputevents oe
			where	oe.itemid in(
						40055, -- "Urine Out Foley"
						43175, -- "Urine ."
						40069, -- "Urine Out Void"
						40094, -- "Urine Out Condom Cath"
						40715, -- "Urine Out Suprapubic"
						40473, -- "Urine Out IleoConduit"
						40085, -- "Urine Out Incontinent"
						40057, -- "Urine Out Rt Nephrostomy"
						40056, -- "Urine Out Lt Nephrostomy"
						40405, -- "Urine Out Other"
						40428, -- "Urine Out Straight Cath"
						40086, --  Urine Out Incontinent
						40096, -- "Urine Out Ureteral Stent #1"
						40651, -- "Urine Out Ureteral Stent #2"

						-- these are the most frequently occurring urine output observations in CareVue
						226559, -- "Foley"
						226560, -- "Void"
						226561, -- "Condom Cath"
						226584, -- "Ileoconduit"
						226563, -- "Suprapubic"
						226564, -- "R Nephrostomy"
						226565, -- "L Nephrostomy"
						226567, --	Straight Cath
						226557, -- R Ureteral Stent
						226558, -- L Ureteral Stent
						227488, -- GU Irrigant Volume In
						227489  -- GU Irrigant/Urine Volume Out
						
						--More added:
						/*43171, --"URINE CC/KG/HR"
						43173, -- "urinecc/kg/hr"
						43373, -- urine cc/kg/hr"
						43374, -- "URINE CC?KG?HR"
						43379, -- "URINECC/KG/HR"
						43380, -- "urine outpt cc/kg/hr"
						43431, -- "Urine cc/k/hr"
						43522, -- »Urine cc/kg/hr"
						43576, -- "24hr Urine cc/kg/hr"
						43589, -- "urine cc/k/hr"
						43811, -- "urine out: cc/k/hr"
						43812, -- "urine out:cc/k/hr"
						43856, -- "urine cc/k/ghr"
						45304, -- »Urine output cc/k/hr"
						43333, -- »urine cc's/k/hr"
						43638, -- "urine output cc/k/hr"
						43654*/
						) and
				demo.subject_id=oe.subject_id 
			) as urine
		) as table_urine
	where 	day_24h is not null
	group by icustay_id, day_6h, day_12h, day_24h
	order by icustay_id, day_6h
)

--select * from tab1

, tab2 as --urine 12h
(
select icustay_id
	, day_12h
	, sum(urine_6h) as urine_12h
from tab1
group by icustay_id, day_12h
)	

--select * from tab2

, tab3 as --urine 24h
(
select icustay_id
	, day_24h
	, sum(urine_6h) as urine_24h
from tab1
group by icustay_id, day_24h
)	

--select * from tab3

, tab4 as
(
select tab1.*
	,tab2.urine_12h
	, tab3.urine_24h
from tab1
left join tab2 on tab1.icustay_id=tab2.icustay_id and
		tab1.day_12h=tab2.day_12h
left join tab3 on tab1.icustay_id=tab3.icustay_id and
		tab1.day_24h=tab3.day_24h
order by tab1.icustay_id, tab1.day_6h
)

--select * from tab4

, tab5 as -- merge with weight from demographics_nockd
(
select tab4.*
	, demo.weight
from tab4, public.kentran_1_3_demographics_nockd demo
where tab4.icustay_id=demo.icustay_id
)

, tab6 as --urine output/h/kg
(
select icustay_id
	, day_6h
	, day_12h
	, day_24h
	, (urine_6h)/6/weight as urine_6h_kgh
	, (urine_12h)/12/weight as urine_12h_kgh
	, (urine_24h)/24/weight as urine_24h_kgh
from tab5
) 

select * into public.kentran_8_2_table_urine 
from tab6 order by icustay_id, day_6h;

select * from public.kentran_8_2_table_urine;