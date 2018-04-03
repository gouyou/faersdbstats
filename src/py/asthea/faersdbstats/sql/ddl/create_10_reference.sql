SET search_path = faers;

-- -----------------------------------------------------------------------------
CREATE TABLE country_code
(
  country_name VARCHAR,
  country_code VARCHAR
);

-- -----------------------------------------------------------------------------
CREATE TABLE eu_drug_name_active_ingredient
(
  active_substance    VARCHAR,
  brand_name          VARCHAR,
  eu_number           VARCHAR,
  human_or_veterinary VARCHAR,
  procedure_type      VARCHAR,
  details             VARCHAR
);
CREATE MATERIALIZED VIEW eu_drug_name_active_ingredient_mapping AS
  SELECT DISTINCT
    upper(active_substance) AS active_substance,
    upper(brand_name)       AS brand_name
  FROM eu_drug_name_active_ingredient
  WHERE human_or_veterinary = 'Human' AND
        upper(active_substance) <> 'NOT APPLICABLE' AND brand_name IS NOT NULL
  ORDER BY 1, 2
WITH NO DATA;

-- -----------------------------------------------------------------------------
CREATE TABLE nda
(
  ingredient          VARCHAR,
  dfroute             VARCHAR,
  trade_name          VARCHAR,
  applicant           VARCHAR,
  strength            VARCHAR,
  appl_type           VARCHAR,
  appl_no             VARCHAR,
  product_no          VARCHAR,
  te_code             VARCHAR,
  approval_date       VARCHAR,
  rld                 VARCHAR,
  rs                  VARCHAR,
  type                VARCHAR,
  applicant_full_name VARCHAR,
  drug_form           VARCHAR,
  route               VARCHAR
);
CREATE INDEX nda_ingredient_ix
  ON nda (appl_no, ingredient);
