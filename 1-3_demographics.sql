------------------------------------------------------------
---- CKD - exclusion criteria 
-------------------------------------------------------------
set search_path to mimiciii;
drop table if exists public.kentran_1_3_demographics_nockd;

create table public.kentran_1_3_demographics_nockd as -- exclude patients in the CKD list

(
select --DISTINCT Ken: not sure if we need distinct here, may actually slow it down 
	demographics_select.*
		, weightfirstday.weight
from 
public.kentran_1_2_demographics_select demographics_select
, public.kentran_1_4_weightfirstday weightfirstday
where demographics_select.subject_id NOT IN 
	(
	select diag.subject_id
	from mimiciii.diagnoses_icd diag
	where icd9_code = '5859'
	) 
and
	demographics_select.icustay_id=weightfirstday.icustay_id
	
);

select * from public.kentran_1_3_demographics_nockd
order by subject_id;
