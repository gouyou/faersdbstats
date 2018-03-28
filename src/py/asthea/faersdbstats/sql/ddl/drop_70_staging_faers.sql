SET search_path = faers;

/* -------------------------------------------------------------- demographic */
DROP VIEW IF EXISTS demo;
DROP TABLE IF EXISTS demo_staging_version_a;
DROP TABLE IF EXISTS demo_staging_version_b;

DROP VIEW IF EXISTS demo_legacy;
DROP TABLE IF EXISTS demo_legacy_staging_version_a;
DROP TABLE IF EXISTS demo_legacy_staging_version_b;

/* --------------------------------------------------------------------- drug */
DROP VIEW IF EXISTS drug;
DROP TABLE IF EXISTS drug_staging_version_a;
DROP TABLE IF EXISTS drug_staging_version_b;

DROP TABLE IF EXISTS drug_legacy;

/* --------------------------------------------------------------- indication */
DROP TABLE IF EXISTS indi;

DROP TABLE IF EXISTS indi_legacy;

/* ------------------------------------------------------------------ outcome */
DROP TABLE IF EXISTS outc;

DROP TABLE IF EXISTS outc_legacy;

/* ----------------------------------------------------------------- reaction */
DROP VIEW IF EXISTS reac;
DROP TABLE IF EXISTS reac_staging_version_a;
DROP TABLE IF EXISTS reac_staging_version_b;

DROP TABLE IF EXISTS reac_legacy;

/* ------------------------------------------------------------------- report */
DROP TABLE IF EXISTS rpsr;

DROP TABLE IF EXISTS rpsr_legacy;

/* ------------------------------------------------------------------ therapy */
DROP TABLE IF EXISTS ther;

DROP TABLE IF EXISTS ther_legacy;
