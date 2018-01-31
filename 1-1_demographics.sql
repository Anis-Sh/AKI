-- ------------------------------------------------------------------
-- Title: Detailed information on ICUSTAY_ID
-- Description: This query provides a useful set of information regarding patient
--			ICU stays. The information is combined from the admissions, patients, and
--			icustays tables. It includes age, length of stay, sequence, and expiry flags.
-- MIMIC version: MIMIC-III v1.2
-- Created by: Erin Hong, Alistair Johnson
-- ------------------------------------------------------------------

-- Define which schema to work on
SET search_path TO mimiciii;

-- This query extracts useful demographic/administrative information for patient ICU stays

drop table if exists public.kentran_1_1_demographics;

create table public.kentran_1_1_demographics -- 
as (
select ie.subject_id
, ie.hadm_id
, ie.icustay_id
-- patient level factors
, pat.gender
-- hospital level factors
, adm.ethnicity
, adm.ADMISSION_TYPE
, adm.admittime
, adm.dischtime
, case 
    when adm.deathtime is not null then 'Y' 
    else 'N' 
  end
  as hospital_expire_flag
, case -- ICU Expire
    WHEN adm.deathtime BETWEEN ie.intime and ie.outtime THEN 'Y'
        -- sometimes there are typographical errors in the death date, so check before intime
    WHEN adm.deathtime <= ie.intime THEN 'Y'
    WHEN adm.dischtime <= ie.outtime AND adm.discharge_location = 'DEAD/EXPIRED' THEN 'Y'
    ELSE 'N'
  end as icu_expire_flag
, dense_rank() over (partition by adm.subject_id order by adm.admittime) as hospstay_seq 
-- Ken: old code would give you ICU stay sequence per hospital admission, not the hospital admission sequence. Deleted order by hadm_id, and changed to order by adm.admittime. Use function dense_rank() instead
, case 
    when dense_rank() over (partition by ie.subject_id order by adm.admittime) = 1 then 'Y' 
    else 'N' 
  end
	as first_hosp_stay 
-- Ken: similar to above

-- icu level factors
, ie.intime
, ie.outtime
, round((EXTRACT(EPOCH FROM (ie.intime-pat.dob)) / 60 / 60 / 24 / 365.242) :: NUMERIC, 4) as Age -- Age at ICU admission
, round((EXTRACT(EPOCH FROM (ie.outtime - ie.intime)) / 60 / 60 / 24) :: NUMERIC, 4) as LOS_ICU 
, row_number() over (partition by ie.subject_id, ie.hadm_id order by ie.intime) as icustay_seq

-- first ICU stay *for the current hospitalization*
, CASE
    WHEN DENSE_RANK() OVER (PARTITION BY ie.hadm_id ORDER BY ie.intime) = 1 THEN 'Y'
    ELSE 'N' END AS first_icu_stay


from icustays ie
inner join admissions adm
 on ie.hadm_id = adm.hadm_id
inner join patients pat
 on ie.subject_id = pat.subject_id
where adm.has_chartevents_data = 1 
-- and ie.subject_id <500 -- remove this line to get full data 
order by ie.subject_id, adm.admittime, ie.intime 
);

select * from public.kentran_1_1_demographics
