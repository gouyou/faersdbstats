SET search_path = faers;

-- -----------------------------------------------------------------------------
REFRESH MATERIALIZED VIEW drugname_list;
REFRESH MATERIALIZED VIEW reac_pt_list;
REFRESH MATERIALIZED VIEW casedemo;

-- -----------------------------------------------------------------------------
REFRESH MATERIALIZED VIEW drugname_legacy_list;
REFRESH MATERIALIZED VIEW reac_pt_legacy_list;
REFRESH MATERIALIZED VIEW casedemo_legacy;

-- -----------------------------------------------------------------------------
-- combine all case demographics with drug list and reaction (outcome) lists
-- across all the LAERS legacy data and FAERS current data
INSERT INTO all_casedemo
  SELECT
    'FAERS'               AS database,
    caseid,
    cast(NULL AS VARCHAR) AS isr,
    caseversion,
    i_f_code,
    event_dt,
    age,
    sex,
    reporter_country,
    primaryid,
    drugname_list,
    reac_pt_list,
    fda_dt,
    NULL                  AS imputed_field_name
  FROM casedemo
  UNION
  SELECT
    'LAERS'                        AS database,
    "CASE"                         AS caseid,
    isr,
    cast('0' AS VARCHAR)           AS caseversion,
    i_f_cod                        AS i_f_code,
    event_dt,
    age,
    gndr_cod                       AS sex,
    e.country_code                 AS reporter_country,
    cast("CASE" || '0' AS VARCHAR) AS primaryid,
    drugname_list,
    reac_pt_list,
    fda_dt,
    NULL                           AS imputed_field_name
  FROM casedemo_legacy a
    LEFT OUTER JOIN country_code e
      ON upper(a.reporter_country) = upper(e.country_name);
COMMIT;

-- -----------------------------------------------------------------------------
-- perform single imputation of missing 'key' demographic fields for multiple
-- reports within the same case across all the legacy and current data

-- single imputation of missing event_dt
REFRESH MATERIALIZED VIEW default_all_casedemo_event_dt_keys;
UPDATE all_casedemo a
SET event_dt = default_event_dt, imputed_field_name = 'event_dt'
FROM default_all_casedemo_event_dt_keys d
WHERE a.caseid = d.caseid AND a.age = d.age AND a.sex = d.sex AND
      a.reporter_country = d.reporter_country
      AND a.caseid IS NOT NULL AND a.event_dt IS NULL AND a.age IS NOT NULL AND
      a.sex IS NOT NULL AND a.reporter_country IS NOT NULL;
COMMIT;

-- single imputation of missing age
REFRESH MATERIALIZED VIEW default_all_casedemo_age_keys;
UPDATE all_casedemo a
SET age = default_age, imputed_field_name = 'age'
FROM default_all_casedemo_age_keys d
WHERE a.caseid = d.caseid AND a.event_dt = d.event_dt AND a.sex = d.sex AND
      a.reporter_country = d.reporter_country
      AND a.caseid IS NOT NULL AND a.event_dt IS NOT NULL AND a.age IS NULL AND
      a.sex IS NOT NULL AND a.reporter_country IS NOT NULL;
COMMIT;

-- single imputation of missing gender
REFRESH MATERIALIZED VIEW default_all_casedemo_sex_keys;
UPDATE all_casedemo a
SET sex = default_sex, imputed_field_name = 'sex'
FROM default_all_casedemo_sex_keys d
WHERE a.caseid = d.caseid AND a.event_dt = d.event_dt AND a.age = d.age AND
      a.reporter_country = d.reporter_country
      AND a.caseid IS NOT NULL AND a.event_dt IS NOT NULL AND a.age IS NOT NULL
      AND a.sex IS NULL AND a.reporter_country IS NOT NULL;
COMMIT;

-- single imputation of missing reporter_country
REFRESH MATERIALIZED VIEW default_all_casedemo_reporter_country_keys;
UPDATE all_casedemo a
SET reporter_country = default_reporter_country,
  imputed_field_name = 'reporter_country'
FROM default_all_casedemo_reporter_country_keys d
WHERE a.caseid = d.caseid AND a.event_dt = d.event_dt AND a.age = d.age AND
      a.sex = d.sex
      AND a.caseid IS NOT NULL AND a.event_dt IS NOT NULL AND a.age IS NOT NULL
      AND a.sex IS NOT NULL AND a.reporter_country IS NULL;
COMMIT;

-- -----------------------------------------------------------------------------
REFRESH MATERIALIZED VIEW unique_all_casedemo;
REFRESH MATERIALIZED VIEW unique_all_case;
