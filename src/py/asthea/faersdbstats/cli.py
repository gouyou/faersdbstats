__author__ = 'Guillaume Taglang <guillaume@asthea.com>'

import logging
from pkgutil import get_data

import click
import click_log

from psycopg2 import connect

from asthea.faersdbstats import stage_faers
from asthea.faersdbstats import reference


CREATE_SCHEMA_SQL = (
    'sql/ddl/create_00_schema.sql',
)
CREATE_SQL = (
    'sql/ddl/create_10_reference.sql',
    'sql/ddl/create_11_reference_OMOP_CDM.sql',
    'sql/ddl/create_20_staging_faers.sql',
    'sql/ddl/create_30_deduplication.sql',
)

DROP_SCHEMA_SQL = (
    'sql/ddl/drop_90_schema.sql',
)
DROP_SQL = (
    'sql/ddl/drop_60_deduplication.sql',
    'sql/ddl/drop_70_staging_faers.sql',
    'sql/ddl/drop_79_reference_OMOP_CDM.sql',
    'sql/ddl/drop_80_reference.sql',
)

DEDUPLICATE_SQL = (
    'sql/process_31_deduplication.sql',
)


log = logging.getLogger(__name__)
click_log.basic_config('')


# ----------------------------------------------------------------------- helper
def execute_sql_resources(connection_info, resources):
    log.debug('execute_sql_resources()')

    with connect(connection_info) as connection:
        with connection.cursor() as cursor:
            for sql_location in resources:
                log.debug('Executing {}'.format(sql_location))
                sql = get_data('asthea.faersdbstats', sql_location)

                cursor.execute(sql)


# --------------------------------------------------------------------- commands
@click.group()
@click_log.simple_verbosity_option('')
def run():
    pass


# -------------------------------------------------------------------- DDLs ----
@click.command()
@click.argument('database')
def create_schema(database):
    log.info('Create database schemas')

    execute_sql_resources(database, CREATE_SCHEMA_SQL)


@click.command()
@click.argument('database')
def create(database):
    log.info('Create database structure')

    execute_sql_resources(database, CREATE_SQL)


@click.command()
@click.argument('database')
def drop_schema(database):
    log.info('Drop database schemas')

    execute_sql_resources(database, DROP_SCHEMA_SQL)


@click.command()
@click.argument('database')
def drop(database):
    log.info('Drop database structure')

    execute_sql_resources(database, DROP_SQL)


# ---------------------------------------------------------------- download ----
@click.command()
@click.argument('data_folder')
def download(data_folder):
    log.info('Downloading to {}'.format(data_folder))

    reference.download_orange_book(data_folder)
    stage_faers.download(data_folder)


@click.command()
@click.argument('data_folder')
def download_reference(data_folder):
    log.info('Downloading reference data to {}'.format(data_folder))

    reference.download_orange_book(data_folder)


@click.command()
@click.argument('data_folder')
def download_faers(data_folder):
    log.info('Downloading FAERS data to {}'.format(data_folder))

    stage_faers.download(data_folder)


# -------------------------------------------------------------------- load ----
@click.command()
@click.argument('database')
@click.argument('data_folder')
def load(database, data_folder):
    log.info('Load data')

    reference.load_included(database)
    reference.load_orange_book(database, data_folder)
    stage_faers.load(database, data_folder)


@click.command()
@click.argument('database')
@click.argument('data_folder')
def load_reference(database, data_folder):
    log.info('Load reference data')

    reference.load_included(database)
    reference.load_orange_book(database, data_folder)


@click.command()
@click.argument('database')
@click.argument('data_folder')
def load_faers(database, data_folder):
    log.info('Load FAERS data')

    stage_faers.load(database, data_folder)


# ----------------------------------------------------------------- process ----
@click.command()
@click.argument('database')
def deduplicate(database):
    log.info('Deduplicate FAERS cases')

    execute_sql_resources(database, DEDUPLICATE_SQL)


# ------------------------------------------------------------------------- main
def main():
    log.debug('main()')

    run.add_command(create_schema)
    run.add_command(drop_schema)

    run.add_command(create)
    run.add_command(drop)

    run.add_command(download)
    run.add_command(download_reference)
    run.add_command(download_faers)

    run.add_command(load)
    run.add_command(load_reference)
    run.add_command(load_faers)

    run.add_command(deduplicate)

    run(obj={})


if __name__ == '__main__':
    main()
