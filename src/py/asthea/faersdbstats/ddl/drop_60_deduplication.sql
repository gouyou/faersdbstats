SET search_path = faers;

-- -----------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS unique_all_case;
DROP MATERIALIZED VIEW IF EXISTS unique_all_casedemo;

-- -----------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS default_all_casedemo_reporter_country_keys;
DROP MATERIALIZED VIEW IF EXISTS default_all_casedemo_sex_keys;
DROP MATERIALIZED VIEW IF EXISTS default_all_casedemo_age_keys;
DROP MATERIALIZED VIEW IF EXISTS default_all_casedemo_event_dt_keys;

-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS all_casedemo;

-- -----------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS drugname_legacy_list;
DROP MATERIALIZED VIEW IF EXISTS reac_pt_legacy_list;
DROP MATERIALIZED VIEW IF EXISTS casedemo_legacy;

-- -----------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS casedemo;
DROP MATERIALIZED VIEW IF EXISTS reac_pt_list;
DROP MATERIALIZED VIEW IF EXISTS drugname_list;
