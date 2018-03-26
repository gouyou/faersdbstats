SET search_path = faers;

/* -------------------------------------------------------------- demographic */
CREATE TABLE demo_staging_version_a
(
  primaryid        VARCHAR,
  caseid           VARCHAR,
  caseversion      VARCHAR,
  i_f_code         VARCHAR,
  event_dt         VARCHAR,
  mfr_dt           VARCHAR,
  init_fda_dt      VARCHAR,
  fda_dt           VARCHAR,
  rept_cod         VARCHAR,
  mfr_num          VARCHAR,
  mfr_sndr         VARCHAR,
  age              VARCHAR,
  age_cod          VARCHAR,
  gndr_cod         VARCHAR,
  e_sub            VARCHAR,
  wt               VARCHAR,
  wt_cod           VARCHAR,
  rept_dt          VARCHAR,
  to_mfr           VARCHAR,
  occp_cod         VARCHAR,
  reporter_country VARCHAR,
  occr_country     VARCHAR,
  filename         VARCHAR
);

CREATE TABLE demo_staging_version_b
(
  primaryid        VARCHAR,
  caseid           VARCHAR,
  caseversion      VARCHAR,
  i_f_code         VARCHAR,
  event_dt         VARCHAR,
  mfr_dt           VARCHAR,
  init_fda_dt      VARCHAR,
  fda_dt           VARCHAR,
  rept_cod         VARCHAR,
  auth_num         VARCHAR,
  mfr_num          VARCHAR,
  mfr_sndr         VARCHAR,
  lit_ref          VARCHAR,
  age              VARCHAR,
  age_cod          VARCHAR,
  age_grp          VARCHAR,
  sex              VARCHAR,
  e_sub            VARCHAR,
  wt               VARCHAR,
  wt_cod           VARCHAR,
  rept_dt          VARCHAR,
  to_mfr           VARCHAR,
  occp_cod         VARCHAR,
  reporter_country VARCHAR,
  occr_country     VARCHAR,
  filename         VARCHAR
);

CREATE VIEW demo AS
  SELECT
    primaryid,
    caseid,
    caseversion,
    i_f_code,
    event_dt,
    mfr_dt,
    init_fda_dt,
    fda_dt,
    rept_cod,
    NULL     AS auth_num,
    mfr_num,
    mfr_sndr,
    NULL     AS lit_ref,
    age,
    age_cod,
    NULL     AS age_grp,
    gndr_cod AS sex,
    e_sub,
    wt,
    wt_cod,
    rept_dt,
    to_mfr,
    occp_cod,
    reporter_country,
    occr_country,
    filename
  FROM demo_staging_version_a
  UNION ALL
  SELECT *
  FROM demo_staging_version_b;


CREATE TABLE demo_legacy_staging_version_a
(
  ISR      VARCHAR,
  "CASE"   VARCHAR,
  I_F_COD  VARCHAR,
  FOLL_SEQ VARCHAR,
  IMAGE    VARCHAR,
  EVENT_DT VARCHAR,
  MFR_DT   VARCHAR,
  FDA_DT   VARCHAR,
  REPT_COD VARCHAR,
  MFR_NUM  VARCHAR,
  MFR_SNDR VARCHAR,
  AGE      VARCHAR,
  AGE_COD  VARCHAR,
  GNDR_COD VARCHAR,
  E_SUB    VARCHAR,
  WT       VARCHAR,
  WT_COD   VARCHAR,
  REPT_DT  VARCHAR,
  OCCP_COD VARCHAR,
  DEATH_DT VARCHAR,
  TO_MFR   VARCHAR,
  CONFID   VARCHAR,
  FILENAME VARCHAR
);

CREATE TABLE demo_legacy_staging_version_b
(
  ISR              VARCHAR,
  "CASE"           VARCHAR,
  I_F_COD          VARCHAR,
  FOLL_SEQ         VARCHAR,
  IMAGE            VARCHAR,
  EVENT_DT         VARCHAR,
  MFR_DT           VARCHAR,
  FDA_DT           VARCHAR,
  REPT_COD         VARCHAR,
  MFR_NUM          VARCHAR,
  MFR_SNDR         VARCHAR,
  AGE              VARCHAR,
  AGE_COD          VARCHAR,
  GNDR_COD         VARCHAR,
  E_SUB            VARCHAR,
  WT               VARCHAR,
  WT_COD           VARCHAR,
  REPT_DT          VARCHAR,
  OCCP_COD         VARCHAR,
  DEATH_DT         VARCHAR,
  TO_MFR           VARCHAR,
  CONFID           VARCHAR,
  REPORTER_COUNTRY VARCHAR,
  FILENAME         VARCHAR
);

CREATE VIEW demo_legacy AS
  SELECT
    ISR,
    "CASE",
    I_F_COD,
    FOLL_SEQ,
    IMAGE,
    EVENT_DT,
    MFR_DT,
    FDA_DT,
    REPT_COD,
    MFR_NUM,
    MFR_SNDR,
    AGE,
    AGE_COD,
    GNDR_COD,
    E_SUB,
    WT,
    WT_COD,
    REPT_DT,
    OCCP_COD,
    DEATH_DT,
    TO_MFR,
    CONFID,
    NULL AS REPORTER_COUNTRY,
    FILENAME
  FROM demo_legacy_staging_version_a
  UNION ALL
  SELECT *
  FROM demo_legacy_staging_version_b;

/* --------------------------------------------------------------------- drug */
CREATE TABLE drug_staging_version_a
(
  primaryid     VARCHAR,
  caseid        VARCHAR,
  drug_seq      VARCHAR,
  role_cod      VARCHAR,
  drugname      VARCHAR,
  val_vbm       VARCHAR,
  route         VARCHAR,
  dose_vbm      VARCHAR,
  cum_dose_chr  VARCHAR,
  cum_dose_unit VARCHAR,
  dechal        VARCHAR,
  rechal        VARCHAR,
  lot_nbr       VARCHAR,
  exp_dt        VARCHAR,
  nda_num       VARCHAR,
  dose_amt      VARCHAR,
  dose_unit     VARCHAR,
  dose_form     VARCHAR,
  dose_freq     VARCHAR,
  filename      VARCHAR
);

CREATE TABLE drug_staging_version_b
(
  primaryid     VARCHAR,
  caseid        VARCHAR,
  drug_seq      VARCHAR,
  role_cod      VARCHAR,
  drugname      VARCHAR,
  prod_ai       VARCHAR,
  val_vbm       VARCHAR,
  route         VARCHAR,
  dose_vbm      VARCHAR,
  cum_dose_chr  VARCHAR,
  cum_dose_unit VARCHAR,
  dechal        VARCHAR,
  rechal        VARCHAR,
  lot_num       VARCHAR,
  exp_dt        VARCHAR,
  nda_num       VARCHAR,
  dose_amt      VARCHAR,
  dose_unit     VARCHAR,
  dose_form     VARCHAR,
  dose_freq     VARCHAR,
  filename      VARCHAR
);

CREATE VIEW drug AS
  SELECT
    primaryid,
    caseid,
    drug_seq,
    role_cod,
    drugname,
    NULL    AS prod_ai,
    val_vbm,
    route,
    dose_vbm,
    cum_dose_chr,
    cum_dose_unit,
    dechal,
    rechal,
    lot_nbr AS lot_num,
    exp_dt,
    nda_num,
    dose_amt,
    dose_unit,
    dose_form,
    dose_freq,
    filename
  FROM drug_staging_version_a
  UNION ALL
  SELECT *
  FROM drug_staging_version_b;


CREATE TABLE drug_legacy
(
  ISR      VARCHAR,
  DRUG_SEQ VARCHAR,
  ROLE_COD VARCHAR,
  DRUGNAME VARCHAR,
  VAL_VBM  VARCHAR,
  ROUTE    VARCHAR,
  DOSE_VBM VARCHAR,
  DECHAL   VARCHAR,
  RECHAL   VARCHAR,
  LOT_NUM  VARCHAR,
  EXP_DT   VARCHAR,
  NDA_NUM  VARCHAR,
  FILENAME VARCHAR
);

/* --------------------------------------------------------------- indication */
CREATE TABLE indi
(
  primaryid     VARCHAR,
  caseid        VARCHAR,
  indi_drug_seq VARCHAR,
  indi_pt       VARCHAR,
  filename      VARCHAR
);


CREATE TABLE indi_legacy
(
  ISR      VARCHAR,
  DRUG_SEQ VARCHAR,
  INDI_PT  VARCHAR,
  FILENAME VARCHAR
);

/* ------------------------------------------------------------------ outcome */
CREATE TABLE outc
(
  primaryid VARCHAR,
  caseid    VARCHAR,
  outc_code VARCHAR,
  filename  VARCHAR
);


CREATE TABLE outc_legacy
(
  ISR      VARCHAR,
  OUTC_COD VARCHAR,
  FILENAME VARCHAR
);

/* ----------------------------------------------------------------- reaction */
CREATE TABLE reac_staging_version_a
(
  primaryid VARCHAR,
  caseid    VARCHAR,
  pt        VARCHAR,
  filename  VARCHAR
);

CREATE TABLE reac_staging_version_b
(
  primaryid    VARCHAR,
  caseid       VARCHAR,
  pt           VARCHAR,
  drug_rec_act VARCHAR,
  filename     VARCHAR
);

CREATE VIEW reac AS
  SELECT
    primaryid,
    caseid,
    pt,
    NULL AS drug_rec_act,
    filename
  FROM reac_staging_version_a
  UNION ALL
  SELECT *
  FROM reac_staging_version_b;


CREATE TABLE reac_legacy
(
  ISR      VARCHAR,
  PT       VARCHAR,
  FILENAME VARCHAR
);

/* ------------------------------------------------------------------- report */
CREATE TABLE rpsr
(
  primaryid VARCHAR,
  caseid    VARCHAR,
  rpsr_cod  VARCHAR,
  filename  VARCHAR
);


CREATE TABLE rpsr_legacy
(
  ISR      VARCHAR,
  RPSR_COD VARCHAR,
  FILENAME VARCHAR
);

/* ------------------------------------------------------------------ therapy */
CREATE TABLE ther
(
  primaryid    VARCHAR,
  caseid       VARCHAR,
  dsg_drug_seq VARCHAR,
  start_dt     VARCHAR,
  end_dt       VARCHAR,
  dur          VARCHAR,
  dur_cod      VARCHAR,
  filename     VARCHAR
);


CREATE TABLE ther_legacy
(
  ISR      VARCHAR,
  DRUG_SEQ VARCHAR,
  START_DT VARCHAR,
  END_DT   VARCHAR,
  DUR      VARCHAR,
  DUR_COD  VARCHAR,
  FILENAME VARCHAR
);
