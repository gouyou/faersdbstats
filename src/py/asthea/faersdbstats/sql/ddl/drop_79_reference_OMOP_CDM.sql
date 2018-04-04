SET search_path = cdmv5;

-- Standardized derived elements
DROP TABLE IF EXISTS condition_era;
DROP TABLE IF EXISTS dose_era;
DROP TABLE IF EXISTS drug_era;
DROP TABLE IF EXISTS cohort_attribute;
DROP TABLE IF EXISTS cohort;

-- Standardized health economics
DROP TABLE IF EXISTS cost;
DROP TABLE IF EXISTS payer_plan_period;

-- Standardized health system data
DROP TABLE IF EXISTS provider;
DROP TABLE IF EXISTS care_site;
DROP TABLE IF EXISTS location;

-- Standardized clinical data
DROP TABLE IF EXISTS fact_relationship;
DROP TABLE IF EXISTS observation;
DROP TABLE IF EXISTS note_nlp;
DROP TABLE IF EXISTS note;
DROP TABLE IF EXISTS measurement;
DROP TABLE IF EXISTS condition_occurrence;
DROP TABLE IF EXISTS device_exposure;
DROP TABLE IF EXISTS drug_exposure;
DROP TABLE IF EXISTS procedure_occurrence;
DROP TABLE IF EXISTS visit_detail;
DROP TABLE IF EXISTS visit_occurrence;
DROP TABLE IF EXISTS death;
DROP TABLE IF EXISTS specimen;
DROP TABLE IF EXISTS observation_period;
DROP TABLE IF EXISTS person;

-- Standardized meta-data
DROP TABLE IF EXISTS metadata;
DROP TABLE IF EXISTS cdm_source;

-- Standardized vocabulary
DROP TABLE IF EXISTS attribute_definition;
DROP TABLE IF EXISTS cohort_definition;
DROP TABLE IF EXISTS drug_strength;
DROP TABLE IF EXISTS source_to_concept_map;
DROP TABLE IF EXISTS concept_ancestor;
DROP TABLE IF EXISTS concept_synonym;
DROP TABLE IF EXISTS relationship;
DROP TABLE IF EXISTS concept_relationship;
DROP TABLE IF EXISTS concept_class;
DROP TABLE IF EXISTS domain;
DROP TABLE IF EXISTS vocabulary;
DROP TABLE IF EXISTS concept;
