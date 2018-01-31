set search_path to mimiciii;

drop table if exists public.kentran_3_1_database_ventiles_severity;
create table public.kentran_3_1_database_ventiles_severity as
(
select db.*
, apsiii.apsiii as saps3
, sapsii.sapsii as saps2
, sofa.sofa as sofa_total
, sofa.respiration as sofa_respi
, sofa.coagulation as sofa_coag
, sofa.liver as sofa_liver
, sofa.cardiovascular as sofa_cv
, sofa.cns as sofa_neuro
, sofa.renal as sofa_renal
from public.kentran_2_2_database_ventiles db
, public.apsiii apsiii
, public.sapsii sapsii
, public.sofa sofa
where 
db.icustay_id=apsiii.icustay_id 
AND sapsii.icustay_id=db.icustay_id 
AND sofa.icustay_id=db.icustay_id
order by db.icustay_id
);

select * 
from public.kentran_3_1_database_ventiles_severity
order by subject_id, admittime;