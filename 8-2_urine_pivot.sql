
drop table if exists public.kentran_8_2_table_urine_pivot;
with tab1 as(
select distinct 
		icustay_id
		,day_24h
		,urine_24h_kgh
		--,max(day_12h) over(partition by icustay_id, day_24h order by day_12h desc)/day_24h as largest
		--,min(day_12h) over(partition by icustay_id, day_24h order by day_12h)/day_24h as min 
		--,day_12h-2*(day_24h-1) as check2
		
		,case

		-- if min is one then calculate first value, if not null
			when min(day_12h) over(partition by icustay_id, day_24h order by day_12h)/day_24h = 1
			then first_value(urine_12h_kgh) over(partition by icustay_id, day_24h order by day_12h) 
			else null
			end as urine_12h_kgh_1

		-- if max is 2 means that there is a second value, if not null
		,case
			when max(day_12h) over(partition by icustay_id, day_24h order by day_12h desc)/day_24h = 2
			then first_value(urine_12h_kgh) over(partition by icustay_id, day_24h order by day_12h desc) 

			else null

			end as urine_12h_kgh_2

from public.kentran_8_2_table_urine 
-- where icustay_id in (200039, 200067)
order by icustay_id, day_24h
)
-- select * from tab1
, tab2 as
(
select distinct
		icustay_id
		,day_24h
		, case 
			when day_6h in (1,5,9,13,17,21,25)
			then urine_6h_kgh

			end as urine_6h_kgh_1

from public.kentran_8_2_table_urine 
order by icustay_id, day_24h
)
-- select * from tab2 where urine_6h_kgh_1 is not null

, tab3 as 
(
select distinct
		icustay_id
		,day_24h
		, case 
			when day_6h in (2,6,10,14,18,22,26)
			then urine_6h_kgh
			
			end as urine_6h_kgh_2



from public.kentran_8_2_table_urine 
order by icustay_id, day_24h
)
, tab4 as
(
select distinct
		icustay_id
		,day_24h
		, case 
			when day_6h in (3,7,11,15,19,23,27)
			then urine_6h_kgh
			

			end as urine_6h_kgh_3



from public.kentran_8_2_table_urine 
order by icustay_id, day_24h
)
, tab5 as
(
select distinct
		icustay_id
		,day_24h
		, case 
			when day_6h in (4,8,12,16,20,24,28)
			then urine_6h_kgh
			

			end as urine_6h_kgh_4



from public.kentran_8_2_table_urine 
order by icustay_id, day_24h
)
, tab6 as
(
select 
	coalesce(tab1.icustay_id, tab2.icustay_id, tab3.icustay_id, tab4.icustay_id, tab5.icustay_id) as icustay_id
	,coalesce(tab1.day_24h, tab2.day_24h, tab3.day_24h, tab4.day_24h, tab5.day_24h) as day_24h
	,urine_24h_kgh
	,urine_12h_kgh_1
	,urine_12h_kgh_2
	,urine_6h_kgh_1
	,urine_6h_kgh_2
	,urine_6h_kgh_3
	,urine_6h_kgh_4 

from tab1 full outer join (select * from tab2 where tab2.urine_6h_kgh_1 is not null) as tab2
on tab1.icustay_id=tab2.icustay_id and tab1.day_24h=tab2.day_24h

full outer join (select * from tab3 where tab3.urine_6h_kgh_2 is not null) as tab3
on tab1.icustay_id=tab3.icustay_id and tab1.day_24h=tab3.day_24h

full outer join (select * from tab4 where tab4.urine_6h_kgh_3 is not null) as tab4
on tab1.icustay_id=tab4.icustay_id and tab1.day_24h=tab4.day_24h

full outer join (select * from tab5 where tab5.urine_6h_kgh_4 is not null) as tab5
on tab1.icustay_id=tab5.icustay_id and tab1.day_24h=tab5.day_24h
)
select * into public.kentran_8_2_table_urine_pivot from tab6 ;

select * from public.kentran_8_2_table_urine_pivot









