__author__ = 'Guillaume Taglang <guillaume@asthea.com>'

from io import BytesIO
import logging
from pkgutil import get_data

import psycopg2


log = logging.getLogger(__name__)


def load(database):
    log.debug('load()')

    with psycopg2.connect(database) as connection:
        with connection.cursor() as cursor:
            log.info('Loading country codes data')

            cursor.execute('SET search_path = faers')

            sql = 'COPY country_code ' \
                  'FROM STDIN ' \
                  'WITH CSV DELIMITER E\',\' HEADER QUOTE E\'"\''

            data = get_data(
                'asthea.faersdbstats', 'data/ISO_3166-1_country_codes.csv'
            )
            cursor.copy_expert(sql, BytesIO(data))

            data = get_data(
                'asthea.faersdbstats', 'data/non_standard_country_codes.csv'
            )
            cursor.copy_expert(sql, BytesIO(data))
