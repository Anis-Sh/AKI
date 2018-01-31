set search_path to mimiciii;

drop table if exists public.kentran_7_1_tab_norepi;
drop table if exists public.kentran_7_1_tab_epi;
drop table if exists public.kentran_7_1_tab_dopamine;
drop table if exists public.kentran_7_1_tab_dobutamine;
drop table if exists public.kentran_7_1_tab_vasopressine;

-------------------------- * NOREPI* --------------------------------------------------------
with vasocv1 as
(
  select
    icustay_id, charttime
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(case when itemid in (30047,30120) then 1 else 0 end) as vaso -- norepinephrine
  from inputevents_cv
  where itemid in (30047,30120) -- norepinephrine
  --and icustay_id = 200059
  and icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
  group by icustay_id, charttime
)

--select * from vasocv1 order by icustay_id, charttime

, tab2 as
(
select d.icustay_id, d.admittime, v.charttime, 
	case
	when (charttime-admittime) <= '24:00:00' then 1
	when (charttime-admittime) between '24:00:01' and '48:00:00' then 2
	when (charttime-admittime) between'48:00:01' and '72:00:00' then 3
	when (charttime-admittime) between '72:00:01' and '96:00:00' then 4
	when (charttime-admittime) between '96:00:01' and '120:00:00' then 5
	when (charttime-admittime) between '120:00:01' and '144:00:00' then 6
	when (charttime-admittime) between '144:00:01' and '168:00:00' then 7
	else NULL
	end as day
from public.kentran_1_3_demographics_nockd d, vasocv1 v
where d.icustay_id=v.icustay_id 
order by d.icustay_id
)

--select * from tab2

, tab3 as 
(
select tab2.icustay_id, tab2.day, 
	case
	when sum(v.vaso)>0 then 1
	else 0
	end as norepi
from vasocv1 v, tab2
where v.icustay_id=tab2.icustay_id
group by tab2.icustay_id, tab2.day
)
select * into  public.kentran_7_1_tab_norepi  
from tab3 where tab3.day is not null order by tab3.icustay_id, tab3.day;
  
--select * from public.kentran_7_1_tab_norepi  

---------------------------------------------------------------------------------------------------------

-------------------------- * EPI* --------------------------------------------------------
with vasocv1 as
(
  select
    icustay_id
    , charttime
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(case when itemid in (30044,30119,30309) then 1 else 0 end) as vaso -- epinephrine
  from mimiciii.inputevents_cv
  where itemid in (30044,30119,30309) -- epinephrine
  --and icustay_id = 200059
  and icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
  group by icustay_id, charttime
)

--select * from vasocv1 order by icustay_id, charttime

, tab2 as
(
select d.icustay_id, d.admittime, v.charttime, 
	case
	when (charttime-admittime) <= '24:00:00' then 1
	when (charttime-admittime) between '24:00:01' and '48:00:00' then 2
	when (charttime-admittime) between'48:00:01' and '72:00:00' then 3
	when (charttime-admittime) between '72:00:01' and '96:00:00' then 4
	when (charttime-admittime) between '96:00:01' and '120:00:00' then 5
	when (charttime-admittime) between '120:00:01' and '144:00:00' then 6
	when (charttime-admittime) between '144:00:01' and '168:00:00' then 7
	else NULL
	end as day
from public.kentran_1_3_demographics_nockd d, vasocv1 v
where d.icustay_id=v.icustay_id 
order by d.icustay_id
)

--select * from tab2

, tab3 as 
(
select tab2.icustay_id, tab2.day, 
	case
	when sum(v.vaso)>0 then 1
	else 0
	end as epi
from vasocv1 v, tab2
where v.icustay_id=tab2.icustay_id
group by tab2.icustay_id, tab2.day
)
select * into  public.kentran_7_1_tab_epi  
from tab3 where tab3.day is not null order by tab3.icustay_id, tab3.day;

--select * from public.kentran_7_1_tab_epi; 

---------------------------------------------------------------------------------------------------------

-------------------------- * DOPAMINE* --------------------------------------------------------
with vasocv1 as
(
  select
    icustay_id, charttime
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(case when itemid in (30043,30307) then 1 else 0 end) as vaso -- dopamine
  from inputevents_cv
  where itemid in (30043,30307) -- dopamine
  --and icustay_id = 200059
  and icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
  group by icustay_id, charttime
)

--select * from vasocv1 order by icustay_id, charttime

, tab2 as
(
select d.icustay_id, d.admittime, v.charttime, 
	case
	when (charttime-admittime) <= '24:00:00' then 1
	when (charttime-admittime) between '24:00:01' and '48:00:00' then 2
	when (charttime-admittime) between'48:00:01' and '72:00:00' then 3
	when (charttime-admittime) between '72:00:01' and '96:00:00' then 4
	when (charttime-admittime) between '96:00:01' and '120:00:00' then 5
	when (charttime-admittime) between '120:00:01' and '144:00:00' then 6
	when (charttime-admittime) between '144:00:01' and '168:00:00' then 7
	else NULL
	end as day
from public.kentran_1_3_demographics_nockd d, vasocv1 v
where d.icustay_id=v.icustay_id 
order by d.icustay_id
)

--select * from tab2

, tab3 as 
(
select tab2.icustay_id, tab2.day, 
	case
	when sum(v.vaso)>0 then 1
	else 0
	end as dopamine
from vasocv1 v, tab2
where v.icustay_id=tab2.icustay_id
group by tab2.icustay_id, tab2.day
)
select * into  public.kentran_7_1_tab_dopamine  
from tab3 where tab3.day is not null order by tab3.icustay_id, tab3.day;

--select * from public.kentran_7_1_tab_dopamine; 

---------------------------------------------------------------------------------------------------------

-------------------------- * DOBUTAMINE* --------------------------------------------------------
with vasocv1 as
(
  select
    icustay_id, charttime
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(case when itemid in (30042,30306) then 1 else 0 end) as vaso -- dobutamine
  from inputevents_cv
  where itemid in (30042,30306) -- dobutamine
  --and icustay_id = 200059
  and icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
  group by icustay_id, charttime
)

--select * from vasocv1 order by icustay_id, charttime

, tab2 as
(
select d.icustay_id, d.admittime, v.charttime, 
	case
	when (charttime-admittime) <= '24:00:00' then 1
	when (charttime-admittime) between '24:00:01' and '48:00:00' then 2
	when (charttime-admittime) between'48:00:01' and '72:00:00' then 3
	when (charttime-admittime) between '72:00:01' and '96:00:00' then 4
	when (charttime-admittime) between '96:00:01' and '120:00:00' then 5
	when (charttime-admittime) between '120:00:01' and '144:00:00' then 6
	when (charttime-admittime) between '144:00:01' and '168:00:00' then 7
	else NULL
	end as day
from public.kentran_1_3_demographics_nockd d, vasocv1 v
where d.icustay_id=v.icustay_id 
order by d.icustay_id
)

--select * from tab2

, tab3 as 
(
select tab2.icustay_id, tab2.day, 
	case
	when sum(v.vaso)>0 then 1
	else 0
	end as dobutamine
from vasocv1 v, tab2
where v.icustay_id=tab2.icustay_id
group by tab2.icustay_id, tab2.day
)
select * into  public.kentran_7_1_tab_dobutamine  
from tab3 where tab3.day is not null order by tab3.icustay_id, tab3.day;

select * from public.kentran_7_1_tab_dobutamine;
---------------------------------------------------------------------------------------------------------


-------------------------- * VASOPRESSINE* --------------------------------------------------------
with vasocv1 as
(
  select
    icustay_id, charttime
    -- case statement determining whether the ITEMID is an instance of vasopressor usage
    , max(case when itemid in (30051) then 1 else 0 end) as vaso -- vasopressine
  from mimiciii.inputevents_cv
  where itemid in (30051) -- vasopressine
  --and icustay_id = 200059
  and icustay_id in (select icustay_id from public.kentran_1_3_demographics_nockd) -- Ken: speed up by only querying our cohort
  group by icustay_id, charttime
)

--select * from vasocv1 order by icustay_id, charttime

, tab2 as
(
select d.icustay_id, d.admittime, v.charttime, 
	case
	when (charttime-admittime) <= '24:00:01' then 1
	when (charttime-admittime) between '24:00:01' and '48:00:00' then 2
	when (charttime-admittime) between'48:00:01' and '72:00:00' then 3
	when (charttime-admittime) between '72:00:01' and '96:00:00' then 4
	when (charttime-admittime) between '96:00:01' and '120:00:00' then 5
	when (charttime-admittime) between '120:00:01' and '144:00:00' then 6
	when (charttime-admittime) between '144:00:01' and '168:00:00' then 7
	else NULL
	end as day
from public.kentran_1_3_demographics_nockd d, vasocv1 v
where d.icustay_id=v.icustay_id 
order by d.icustay_id
)

--select * from tab2

, tab3 as 
(
select tab2.icustay_id, tab2.day, 
	case
	when sum(v.vaso)>0 then 1
	else 0
	end as vasopressine
from vasocv1 v, tab2
where v.icustay_id=tab2.icustay_id
group by tab2.icustay_id, tab2.day
)
select * into  public.kentran_7_1_tab_vasopressine  
from tab3 where tab3.day is not null order by tab3.icustay_id, tab3.day;

select * from public.kentran_7_1_tab_vasopressine;
---------------------------------------------------------------------------------------------------------


select * from public.kentran_7_1_tab_norepi;
select * from public.kentran_7_1_tab_epi;
select * from public.kentran_7_1_tab_dopamine;
select * from public.kentran_7_1_tab_dobutamine;
select * from public.kentran_7_1_tab_vasopressine;
