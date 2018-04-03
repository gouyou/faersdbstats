SET search_path = faers;

DROP INDEX IF EXISTS nda_ingredient_ix;
DROP TABLE IF EXISTS nda;

-- -----------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS eu_drug_name_active_ingredient_mapping;
DROP TABLE IF EXISTS eu_drug_name_active_ingredient;

-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS country_code;