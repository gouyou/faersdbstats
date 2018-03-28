## Starting
After installing the [anaconda python distribution](https://www.anaconda.com/distribution/) and cloning the repository:
```bash
conda create -n faersdbstats
source activate faersdbstats
conda install psycopg2 requests click
pip install click_log
pip install -e .
```

Download data:
```bash
mkdir data
faersdbstat download data
```

Create structure, load and process data:
```bash
faersdbstat create_schema 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat create 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat load_reference 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat load_faers 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>' data
faersdbstat deduplicate 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
```

## Notes on deduplication
Transform the LAERS legacy demo data into the same format as the FAERS current
data so we can combine demographic data across both databases and run logic to
remove duplicate cases across them both

There is no real LAERS case version so we default to '0' to ensure that LAERS
data will sort before FAERS data case version (FAERS case version is always
populated and never less than '1').

There is no real LAERS primaryid but we generate it from CASE and case version.

We translate LAERS country names to FAERS 2 char country codes with a join to
the country_code table

We perform single imputation of missing 'key' demographic fields for multiple
reports within the same case producing a new table demo_with_imputed_keys.

We followed the single imputation process in the book _"Data Mining
Applications in Engineering and Medicine"_ by Elisabetta Poluzzi, Emanuel
Raschil, Carlo Piccinni and Fabrizio De Ponti (ISBN 978-953-51-0720-0). See
Chapter 12: _Data Mining Techniques in Pharmacovigilance: Analysis of the
Publicly Accessible FDA Adverse Event Reporting System (AERS)_. We use the same
demographic key fields:  age, event_dt, sex, reporter_country.

The 'key' demographic fields are required in later processing to remove
duplicate cases.

We will only impute single missing case demo key values for a case where there
is at least one case record with a fully populated set of demo keys and we
populate (impute) the value of a missing demo key field using the max value of
the demo key field for the same case.
