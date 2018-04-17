# Instructions to execute the standardize FAERS data and generate safety signals ETL process

[Asthea Consulting Ltd](https://asthea.com/) 

[LTS Computing LLC](http://www.ltscomputingllc.com/)


## Development
The source code (shell scripts and SQL scripts) was originally developed by LTS 
Computing LLC, a second python based version is being developed by Asthea
Consulting Ltd. The source code is available on 
[github](https://github.com/gouyou/faersdbstats) and is licensed under the 
Apache 2.0 license.

## System Prerequisites
1.  Python 3.5 or later: the tool was developed using python 3.5.
2.  PostgreSQL 9.5 r later: the tool was developed using PostgreSQL 9.5.

## Process
1.  Install the tool
2.  Download required data
3.  Create database structures
4.  Load legacy AERS and FAERS data

### Installation
After installing [anaconda](https://www.anaconda.com/distribution/), create an
environment and install the tool:
```bash
conda create -n faersdbstats
source activate faersdbstats
conda install psycopg2 requests click
pip install git+https://github.com/gouyou/faersdbstats.git
```

### Download required data
```bash
mkdir data
faersdbstat download data
```

Download the OHDSI CDM v5 vocabulary from the
[OHDSI Athena Website](http://athena.ohdsi.org/). On the Athena website
vocabulary download page keep the pre-selected vocabularies and also select the
MedDRA vocabulary (you might need a subscription for
[MedDRA](https://www.meddra.org/)). The downloaded file should be placed in the
download folder you are using (`data`) and be named
`vocabulary_download_v5_<...>.zip`.

### Create database structures
```bash
faersdbstat create_schema 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat create 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
```

### Load Reference data
```bash
faersdbstat load_reference 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>' data
```

### Load legacy AERS and FAERS data
```bash
faersdbstat load_faers 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>' data
```

### Deduplicate case data
