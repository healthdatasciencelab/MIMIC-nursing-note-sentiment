


-- Query for getting patients (patients_df.csv)

WITH tab1 AS 
(
SELECT p.subject_id
	, a.hadm_id
	, a.admittime
	, p.dob
	, p.dod
	, p.dod_hosp
	, p.dod_ssn
    , p.gender 
	, p.expire_flag
    , case
    	when a.admittime = MIN (a.admittime) OVER (PARTITION BY p.subject_id) then 1
    	when a.admittime != MIN (a.admittime) OVER (PARTITION BY p.subject_id) then 0
    	end AS first_admission
    , ROUND( (cast(admittime as date) - cast(dob as date)) / 365.242,2)
        AS first_admit_age
FROM mimiciii.admissions a
INNER JOIN mimiciii.patients p
ON p.subject_id = a.subject_id
ORDER BY p.subject_id, a.hadm_id) 
, tab2 AS
(
select subject_id
	, hadm_id
	, icustay_id
	, dbsource
	, first_careunit
	, case
    	when intime = MIN (intime) OVER (PARTITION BY hadm_id) then 1
    	when intime != MIN (intime) OVER (PARTITION BY hadm_id) then 0
    	end AS first_icu
from mimiciii.icustays
order by subject_id, icustay_id

)


, tab3 as
(
select tab1.*
	, tab2.icustay_id
	, tab2.dbsource
	, tab2.first_careunit
	, tab2.first_icu


from tab1 
inner join tab2 
on tab1.subject_id = tab2.subject_id and tab1.hadm_id = tab2.hadm_id
where tab1.first_admission = 1 and tab2.first_icu = 1 and tab1.first_admit_age >=15


) 

, tab4 as
(
select tab3.*
	, case 
		when round((EXTRACT(EPOCH FROM (tab3.dod - tab3.admittime)) / 60 / 60 / 24)) <= 30 then 1
		else 0
		end as thirty_day_mortality
from tab3
) select * from tab4;



-- Query for getting notes (notes_df.csv)


WITH tab1 AS 
(
SELECT p.subject_id
	, a.hadm_id
	, a.admittime
	, p.dob
	, p.dod
	, p.dod_hosp
	, p.dod_ssn
    , p.gender 
	, p.expire_flag
    , case
    	when a.admittime = MIN (a.admittime) OVER (PARTITION BY p.subject_id) then 1
    	when a.admittime != MIN (a.admittime) OVER (PARTITION BY p.subject_id) then 0
    	end AS first_admission
    , ROUND( (cast(admittime as date) - cast(dob as date)) / 365.242,2)
        AS first_admit_age
FROM mimiciii.admissions a
INNER JOIN mimiciii.patients p
ON p.subject_id = a.subject_id
ORDER BY p.subject_id, a.hadm_id) 
, tab2 AS
(
select subject_id
	, hadm_id
	, icustay_id
	, dbsource
	, first_careunit
	, case
    	when intime = MIN (intime) OVER (PARTITION BY hadm_id) then 1
    	when intime != MIN (intime) OVER (PARTITION BY hadm_id) then 0
    	end AS first_icu
from mimiciii.icustays
order by subject_id, icustay_id

)


, tab3 as
(
select tab1.*
	, tab2.icustay_id
	, tab2.dbsource
	, tab2.first_careunit
	, tab2.first_icu


from tab1 
inner join tab2 
on tab1.subject_id = tab2.subject_id and tab1.hadm_id = tab2.hadm_id
where tab1.first_admission = 1 and tab2.first_icu = 1 and tab1.first_admit_age >=15


)

, tab4 as
(
select tab3.*
	, case 
		when round((EXTRACT(EPOCH FROM (tab3.dod - tab3.admittime)) / 60 / 60 / 24)) <= 30 then 1
		else 0
		end as thirty_day_mortality
from tab3
) select * 
from mimiciii.noteevents
where hadm_id in (select hadm_id from tab3) and category in ('Nursing/other', 'Nursing')
order by subject_id;



-- Query for getting SAPS-II (sapsii_df.csv)


WITH tab1 AS 
(
SELECT p.subject_id
	, a.hadm_id
	, a.admittime
	, p.dob
	, p.dod
	, p.dod_hosp
	, p.dod_ssn
    , p.gender 
	, p.expire_flag
    , case
    	when a.admittime = MIN (a.admittime) OVER (PARTITION BY p.subject_id) then 1
    	when a.admittime != MIN (a.admittime) OVER (PARTITION BY p.subject_id) then 0
    	end AS first_admission
    , ROUND( (cast(admittime as date) - cast(dob as date)) / 365.242,2)
        AS first_admit_age
FROM mimiciii.admissions a
INNER JOIN mimiciii.patients p
ON p.subject_id = a.subject_id
ORDER BY p.subject_id, a.hadm_id) 
, tab2 AS
(
select subject_id
	, hadm_id
	, icustay_id
	, dbsource
	, first_careunit
	, case
    	when intime = MIN (intime) OVER (PARTITION BY hadm_id) then 1
    	when intime != MIN (intime) OVER (PARTITION BY hadm_id) then 0
    	end AS first_icu
from mimiciii.icustays
order by subject_id, icustay_id

)


, tab3 as
(
select tab1.*
	, tab2.icustay_id
	, tab2.dbsource
	, tab2.first_careunit
	, tab2.first_icu


from tab1 
inner join tab2 
on tab1.subject_id = tab2.subject_id and tab1.hadm_id = tab2.hadm_id
where tab1.first_admission = 1 and tab2.first_icu = 1 and tab1.first_admit_age >=15


)

, tab4 as
(
select tab3.*
	, case 
		when round((EXTRACT(EPOCH FROM (tab3.dod - tab3.admittime)) / 60 / 60 / 24)) <= 30 then 1
		else 0
		end as thirty_day_mortality
from tab3
)
select * 
from mimiciii_dev.sapsii
where icustay_id in (select icustay_id from tab4)
order by subject_id


-- Query for getting MIMIC-II patients (mimic2_patients_df.csv)

select * from mimic2v26.d_patients

-- Query for getting MIMIC-II admissions (mimic2_admissions_df.csv)

select * from mimic2v26.admissions


