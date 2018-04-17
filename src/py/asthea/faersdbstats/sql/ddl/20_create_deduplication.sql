SET search_path = faers;

-- -----------------------------------------------------------------------------
-- concatenate string of current drugnames by primaryid
CREATE MATERIALIZED VIEW drugname_list AS
  SELECT
    primaryid,
    upper(string_agg(drugname, '|'
          ORDER BY drugname)) AS drugname_list
  FROM drug
  GROUP BY primaryid
WITH NO DATA;

-- concatenate string of reaction preferred terms by primaryid
CREATE MATERIALIZED VIEW reac_pt_list AS
  SELECT
    primaryid,
    upper(string_agg(pt, '|'
          ORDER BY pt)) AS reac_pt_list
  FROM reac
  GROUP BY primaryid
WITH NO DATA;

-- current data demographics by caseid
CREATE MATERIALIZED VIEW casedemo AS
  SELECT
    caseid,
    caseversion,
    i_f_code,
    event_dt,
    age,
    sex,
    reporter_country,
    d.primaryid,
    drugname_list,
    reac_pt_list,
    fda_dt
  FROM demo d
    LEFT OUTER JOIN drugname_list dl
      ON d.primaryid = dl.primaryid
    LEFT OUTER JOIN reac_pt_list rpl
      ON d.primaryid = rpl.primaryid
WITH NO DATA;

-- -----------------------------------------------------------------------------
-- concatenate string of legacy drugnames by isr
CREATE MATERIALIZED VIEW drugname_legacy_list AS
  SELECT
    isr,
    upper(string_agg(drugname, '|'
          ORDER BY drugname)) AS drugname_list
  FROM drug_legacy
  GROUP BY isr
WITH NO DATA;

-- concatenate string of legacy reaction preferred terms by isr
CREATE MATERIALIZED VIEW reac_pt_legacy_list AS
  SELECT
    isr,
    upper(string_agg(pt, '|'
          ORDER BY pt)) AS reac_pt_list
  FROM reac_legacy
  GROUP BY isr
WITH NO DATA;

-- legacy case demographics by case id
CREATE MATERIALIZED VIEW casedemo_legacy AS
  SELECT
    "CASE",
    i_f_cod,
    event_dt,
    age,
    gndr_cod,
    reporter_country,
    d.isr,
    drugname_list,
    reac_pt_list,
    fda_dt
  FROM demo_legacy d
    LEFT OUTER JOIN drugname_legacy_list dl
      ON d.isr = dl.isr
    LEFT OUTER JOIN reac_pt_legacy_list rpl
      ON d.isr = rpl.isr
WITH NO DATA;

-- -----------------------------------------------------------------------------
CREATE TABLE all_casedemo (
  database           VARCHAR,
  caseid             VARCHAR,
  isr                VARCHAR,
  caseversion        VARCHAR,
  i_f_code           VARCHAR,
  event_dt           VARCHAR,
  age                VARCHAR,
  sex                VARCHAR,
  reporter_country   VARCHAR,
  primaryid          VARCHAR,
  drugname_list      VARCHAR,
  reac_pt_list       VARCHAR,
  fda_dt             VARCHAR,
  imputed_field_name VARCHAR
);

-- -----------------------------------------------------------------------------
-- default demo event_dt key value for each case where all the key fields are
-- populated on at least one report for that case
CREATE MATERIALIZED VIEW default_all_casedemo_event_dt_keys AS
  SELECT
    caseid,
    age,
    sex,
    reporter_country,
    max(event_dt) AS default_event_dt
  FROM all_casedemo
  WHERE caseid IS NOT NULL AND event_dt IS NOT NULL AND age IS NOT NULL AND
        sex IS NOT NULL AND reporter_country IS NOT NULL
  GROUP BY caseid, age, sex, reporter_country
WITH NO DATA;

-- default demo age key value for each case where all the keyfields are
-- populated on at least one report for that case
CREATE MATERIALIZED VIEW default_all_casedemo_age_keys AS
  SELECT
    caseid,
    event_dt,
    sex,
    reporter_country,
    max(age) AS default_age
  FROM all_casedemo
  WHERE caseid IS NOT NULL AND event_dt IS NOT NULL AND age IS NOT NULL AND
        sex IS NOT NULL AND reporter_country IS NOT NULL
  GROUP BY caseid, event_dt, sex, reporter_country
WITH NO DATA;

-- default demo gender key value for each case where all the key fields are
-- populated on at least one report for that case
CREATE MATERIALIZED VIEW default_all_casedemo_sex_keys AS
  SELECT
    caseid,
    event_dt,
    age,
    reporter_country,
    max(sex) AS default_sex
  FROM all_casedemo
  WHERE caseid IS NOT NULL AND event_dt IS NOT NULL AND age IS NOT NULL AND
        sex IS NOT NULL AND reporter_country IS NOT NULL
  GROUP BY caseid, event_dt, age, reporter_country
WITH NO DATA;

-- default demo reporter_country key value for each case where all the key
-- fields are populated on at least one report for that case
CREATE MATERIALIZED VIEW default_all_casedemo_reporter_country_keys AS
  SELECT
    caseid,
    event_dt,
    age,
    sex,
    max(reporter_country) AS default_reporter_country
  FROM all_casedemo
  WHERE caseid IS NOT NULL AND event_dt IS NOT NULL AND age IS NOT NULL AND
        sex IS NOT NULL AND reporter_country IS NOT NULL
  GROUP BY caseid, event_dt, age, sex
WITH NO DATA;

-- -----------------------------------------------------------------------------
-- latest case row for each case across both the legacy LAERS and current FAERS
-- data based on CASE ID
CREATE MATERIALIZED VIEW unique_all_casedemo AS
  SELECT
    database,
    caseid,
    isr,
    caseversion,
    i_f_code,
    event_dt,
    age,
    sex,
    reporter_country,
    primaryid,
    drugname_list,
    reac_pt_list,
    fda_dt
  FROM (
         SELECT
           *,
           row_number()
           OVER (
             PARTITION BY caseid
             ORDER BY primaryid DESC, database DESC, fda_dt DESC, i_f_code,
               isr DESC ) AS row_num
         FROM all_casedemo
       ) a
  WHERE a.row_num = 1
WITH NO DATA;

-- remove any duplicates based on fully populated matching demographic key
-- fields and exact match on list of drugs and list of outcomes (FAERS
-- reactions)
-- NOTE. when using this view for subsequent joins in the ETL process, join to
-- FAERS data using primaryid and join to LAERS data using isr
CREATE MATERIALIZED VIEW unique_all_case AS
  SELECT
    caseid,
    CASE WHEN isr IS NOT NULL
      THEN NULL
    ELSE primaryid END AS primaryid,
    isr
  FROM (
         SELECT
           caseid,
           primaryid,
           isr,
           row_number()
           OVER (
             PARTITION BY event_dt, age, sex, reporter_country, drugname_list, reac_pt_list
             ORDER BY primaryid DESC, database DESC, fda_dt DESC, i_f_code,
               isr DESC ) AS row_num
         FROM unique_all_casedemo
         WHERE
           caseid IS NOT NULL AND event_dt IS NOT NULL AND age IS NOT NULL AND
           sex IS NOT NULL AND reporter_country IS NOT NULL AND
           drugname_list IS NOT NULL AND reac_pt_list IS NOT NULL
       ) a
  WHERE a.row_num = 1
  UNION
  SELECT
    caseid,
    CASE WHEN isr IS NOT NULL
      THEN NULL
    ELSE primaryid END AS primaryid,
    isr
  FROM unique_all_casedemo
  WHERE caseid IS NULL OR event_dt IS NULL OR age IS NULL OR sex IS NULL OR
        reporter_country IS NULL OR drugname_list IS NULL OR
        reac_pt_list IS NULL
WITH NO DATA;
