__author__ = 'Guillaume Taglang <guillaume@asthea.com>'

import errno
import glob
from io import BytesIO
import logging
import os.path
import os
from pkgutil import get_data
from urllib.parse import urljoin
from zipfile import ZipFile

from bs4 import BeautifulSoup

import psycopg2

import requests


log = logging.getLogger(__name__)


def load_included(database):
    log.debug('load_included()')

    with psycopg2.connect(database) as connection:
        with connection.cursor() as cursor:
            # country codes
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

            # EU drugs
            log.info('Loading EU drugs data')

            sql = 'COPY eu_drug_name_active_ingredient ' \
                  'FROM STDIN ' \
                  'WITH CSV DELIMITER E\'\\t\' HEADER QUOTE E\'"\''

            data = get_data(
                'asthea.faersdbstats',
                'data/EU_registered_drugs_by_active_ingredient_utf8.txt'
            )
            cursor.copy_expert(sql, BytesIO(data))

            cursor.execute(
                'REFRESH MATERIALIZED VIEW '
                'eu_drug_name_active_ingredient_mapping;'
            )


def download_orange_book(data_folder):
    log.debug('download_orange_book()')

    log.info('Downloading Orange Book data')
    # get Orange Book page link
    fda_drugs_link = 'https://www.fda.gov' \
                     '/Drugs/InformationOnDrugs/ApprovedDrugs/default.htm'
    r = requests.get(fda_drugs_link)
    soup = BeautifulSoup(r.text, 'html.parser')
    for link in soup.find_all('a'):
        if link.get_text(strip=True) == 'Orange Book':
            ob_page_link = link['href']
            break
    ob_page_link = urljoin(fda_drugs_link, ob_page_link)
    log.debug(ob_page_link)

    # get Orange Book data link
    r = requests.get(ob_page_link)
    soup = BeautifulSoup(r.text, 'html.parser')
    for link in soup.find_all('a'):
        if link.get_text(strip=True).startswith('Orange Book Data Files'):
            ob_data_link = link['href']
            break
    ob_data_link = urljoin(ob_page_link, ob_data_link)
    log.debug(ob_data_link)

    r = requests.get(ob_data_link)
    if r.ok:
        f = open(os.path.join(data_folder, 'orange_book.zip'), 'wb')
        f.write(r.content)
    else:
        log.error('Failed with code {} to download {} ({})'.format(
            r.status_code, r.url, r.reason
        ))


def load_orange_book(database, data_folder):
    log.debug('load_orange_book()')

    with ZipFile(os.path.join(data_folder, 'orange_book.zip')) as z:
        log.info('Processing {}'.format(z.filename))

        for zipinfo in z.infolist():
            if not zipinfo.filename.endswith('products.txt'):
                continue

            with z.open(zipinfo) as f:
                header = f.readline()
                log.debug(header)
                data = f.read()

                with psycopg2.connect(database) as connection:
                    with connection.cursor() as cursor:
                        cursor.execute('SET search_path = faers')

                        sql = 'COPY nda (' \
                              '    ingredient,' \
                              '    dfroute,' \
                              '    trade_name,' \
                              '    applicant,' \
                              '    strength,' \
                              '    appl_type,' \
                              '    appl_no,' \
                              '    product_no,' \
                              '    te_code,' \
                              '    approval_date,' \
                              '    rld,' \
                              '    rs,' \
                              '    type,' \
                              '    applicant_full_name' \
                              ') ' \
                              'FROM STDIN ' \
                              'WITH CSV DELIMITER E\'~\' QUOTE E\'\\b\''
                        cursor.copy_expert(sql, BytesIO(data))

                        sql = 'UPDATE nda ' \
                              'SET drug_form = substring(' \
                              'dfroute FROM \'(.*);\'' \
                              ');'
                        cursor.execute(sql)
                        sql = 'UPDATE nda ' \
                              'SET route = substring(' \
                              'dfroute FROM \';(.*)\'' \
                              ');'
                        cursor.execute(sql)


def load_cdm_vocabulary(database, data_folder):
    log.debug('load_cdm_vocabulary()')

    filename = os.path.join(data_folder, 'vocabulary_download_v5_*.zip')
    filenames = glob.glob(filename)

    if len(filenames) == 0:
        msg = 'Couldn''t find CDM vocabulary file.'
        log.error(msg)
        raise FileNotFoundError(errno.ENOENT, msg, filename)
    elif len(filenames) > 1:
        msg = 'Multiple CDM vocabulary files.'
        log.error(msg)
        raise FileNotFoundError(errno.ENOENT, msg, filename)

    with ZipFile(filenames[0]) as z:
        log.info('Processing {}'.format(z.filename))

        for tablename in [
            'DRUG_STRENGTH',
            'CONCEPT',
            'CONCEPT_RELATIONSHIP',
            'CONCEPT_ANCESTOR',
            'CONCEPT_SYNONYM',
            'VOCABULARY',
            'RELATIONSHIP',
            'CONCEPT_CLASS',
            'DOMAIN'
        ]:
            with z.open(tablename + '.csv') as f:
                log.debug('Loading {}'.format(tablename))
                header = f.readline()
                log.debug(header)
                data = f.read()

                with psycopg2.connect(database) as connection:
                    with connection.cursor() as cursor:
                        cursor.execute('SET search_path = cdmv5')

                        sql = 'COPY {} ' \
                              'FROM STDIN ' \
                              'WITH CSV DELIMITER E\'\\t\' QUOTE E\'\\b\''
                        sql = sql.format(tablename)
                        cursor.copy_expert(sql, BytesIO(data))
