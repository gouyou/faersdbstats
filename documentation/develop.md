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

Create structure and load data:
```bash
faersdbstat create_schema 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat create 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat load_reference 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>'
faersdbstat load_faers 'host=<HOST> dbname=<DBNAME> user=<USER> password=<PASSWORD>' data
```
