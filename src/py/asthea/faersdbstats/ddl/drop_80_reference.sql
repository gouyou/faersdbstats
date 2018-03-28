SET search_path = faers;

-- -----------------------------------------------------------------------------
DROP MATERIALIZED VIEW IF EXISTS eu_drug_name_active_ingredient_mapping;
DROP TABLE IF EXISTS eu_drug_name_active_ingredient;

-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS country_code;