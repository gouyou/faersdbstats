__author__ = 'Guillaume Taglang <guillaume@asthea.com>'

import logging
from pkgutil import get_data

import click
import click_log

from psycopg2 import connect

import asthea.faersdbstats.stage_faers as sf
import asthea.faersdbstats.reference as sr


CREATE_SCHEMA_SQL = (
    'ddl/create_00_schema.sql',
)
CREATE_SQL = (
    'ddl/create_10_reference.sql',
    'ddl/create_20_staging_faers.sql',
)
DROP_SCHEMA_SQL = (
    'ddl/drop_90_schema.sql',
)
DROP_SQL = (
    'ddl/drop_70_staging_faers.sql',
    'ddl/drop_80_reference.sql',
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


@click.command()
@click.argument('data_folder')
def download(data_folder):
    log.info('Downloading to {}'.format(data_folder))

    sf.download(data_folder)


@click.command()
@click.argument('database')
def load_reference(database):
    log.info('Load reference data')

    sr.load(database)


@click.command()
@click.argument('database')
@click.argument('data_folder')
def load_faers(database, data_folder):
    log.info('Load FAERS data')

    sf.load(database, data_folder)


# ------------------------------------------------------------------------- main
def main():
    log.debug('main()')

    run.add_command(create_schema)
    run.add_command(drop_schema)

    run.add_command(create)
    run.add_command(drop)

    run.add_command(download)

    run.add_command(load_reference)
    run.add_command(load_faers)

    run(obj={})


if __name__ == '__main__':
    main()
