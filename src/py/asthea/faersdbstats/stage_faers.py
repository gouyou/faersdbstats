__author__ = 'Guillaume Taglang <guillaume@asthea.com>'

import csv
from io import StringIO
from io import TextIOWrapper
import logging
import os.path
from pkgutil import get_data
import re
from zipfile import ZipFile

import psycopg2
from psycopg2.extras import execute_values

import requests


# data_type, type, type_version => delimiters, table
DATA_ELEMENTS = {
    ('demo', 'aers', 'a'): (22, 'demo_legacy_staging_version_a'),
    ('demo', 'aers', 'b'): (23, 'demo_legacy_staging_version_b'),
    ('demo', 'faers', 'a'): (21, 'demo_staging_version_a'),
    ('demo', 'faers', 'b'): (24, 'demo_staging_version_b'),
    ('drug', 'aers', 'a'): (12, 'drug_legacy'),
    ('drug', 'aers', 'b'): (12, 'drug_legacy'),
    ('drug', 'faers', 'a'): (18, 'drug_staging_version_a'),
    ('drug', 'faers', 'b'): (19, 'drug_staging_version_b'),
    ('indi', 'aers', 'a'): (2, 'indi_legacy'),
    ('indi', 'aers', 'b'): (2, 'indi_legacy'),
    ('indi', 'faers', 'a'): (3, 'indi'),
    ('indi', 'faers', 'b'): (3, 'indi'),
    ('outc', 'aers', 'a'): (1, 'outc_legacy'),
    ('outc', 'aers', 'b'): (1, 'outc_legacy'),
    ('outc', 'faers', 'a'): (2, 'outc'),
    ('outc', 'faers', 'b'): (2, 'outc'),
    ('reac', 'aers', 'a'): (2, 'reac_legacy'),
    ('reac', 'aers', 'b'): (2, 'reac_legacy'),
    ('reac', 'faers', 'a'): (2, 'reac_staging_version_a'),
    ('reac', 'faers', 'b'): (3, 'reac_staging_version_b'),
    ('rpsr', 'aers', 'a'): (2, 'rpsr_legacy'),
    ('rpsr', 'aers', 'b'): (2, 'rpsr_legacy'),
    ('rpsr', 'faers', 'a'): (2, 'rpsr'),
    ('rpsr', 'faers', 'b'): (2, 'rpsr'),
    ('ther', 'aers', 'a'): (6, 'ther_legacy'),
    ('ther', 'aers', 'b'): (6, 'ther_legacy'),
    ('ther', 'faers', 'a'): (6, 'ther'),
    ('ther', 'faers', 'b'): (6, 'ther')
}


log = logging.getLogger(__name__)


def get_source_info():
    log.debug('get_source_info()')

    source_info = get_data('asthea.faersdbstats', 'data/faers_data_source.csv')
    reader = csv.reader(source_info.decode().splitlines(), dialect='excel')

    # skip headers
    next(reader)

    for row in reader:
        yield row


def get_zip_file_name(year, quarter, folder=None):
    file_name = year + 'q' + quarter + '.zip'

    if folder:
        return os.path.join(folder, file_name)
    return file_name


def download(data_folder):
    log.info('Downloading data')

    for type, type_version, year, quarter, url, md5sum in get_source_info():
        if url:
            log.info('Downloading FAERS data for {} Q{}'.format(year, quarter))
            r = requests.get(url)
            if r.ok:
                f = open(get_zip_file_name(year, quarter, data_folder), 'wb')
                f.write(r.content)
            else:
                log.error('Failed with code {} to download {} ({})'.format(
                    r.status_code, r.url, r.reason
                ))


def load(database, data_folder):
    log.debug('Loading data')

    for type_, type_version, year, quarter, url, md5sum in get_source_info():
        with ZipFile(get_zip_file_name(year, quarter, data_folder)) as z:
            log.info('Processing {}'.format(z.filename))

            for zipinfo in z.infolist():
                if re.search(r'demo.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'demo'
                elif re.search(r'drug.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'drug'
                elif re.search(r'indi.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'indi'
                elif re.search(r'outc.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'outc'
                elif re.search(r'reac.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'reac'
                elif re.search(r'rpsr.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'rpsr'
                elif re.search(r'ther.*txt$', zipinfo.filename, re.IGNORECASE):
                    data_type = 'ther'
                else:
                    # TODO handle size, stat
                    continue

                data = get_clean_data(
                    z, zipinfo,
                    data_type, type_, type_version, year, quarter
                )

                with psycopg2.connect(database) as connection:
                    with connection.cursor() as cursor:
                        log.info('Loading {} data for {}Q{}'.format(
                            data_type, year, quarter
                        ))

                        cursor.execute('SET search_path = faers')

                        sql = 'COPY {} ' \
                              'FROM STDIN ' \
                              'WITH CSV DELIMITER E\'$\' QUOTE E\'\\b\''
                        sql = sql.format(
                            DATA_ELEMENTS[(data_type, type_, type_version)][1]
                        )

                        cursor.copy_expert(sql, StringIO(data))


def get_clean_data(
        zipfile_, zipinfo, data_type, type_, type_version, year, quarter
):
    log.debug('get_clean_data()')

    filename = '{}{}q{}.txt'.format(data_type, year[2:], quarter).upper()
    delimiters = DATA_ELEMENTS[(data_type, type_, type_version)][0]

    with zipfile_.open(zipinfo) as f:

        header = f.readline()
        log.debug(header)

        buffer = None
        _data = StringIO()
        wrapped_f = TextIOWrapper(f)
        for line in wrapped_f:
            line = line[:-1]

            # remove control-H (ascii 08) and windows line feed chars
            line = line.replace(chr(8), '').replace('\r', '')

            # fix bad data records with embedded \n
            if buffer:
                line = buffer + line
                buffer = None
            if line.count('$') < delimiters:
                buffer = line
                continue

            _data.write(line)

            # add the filename as the last column on each line
            if data_type == 'indi' and type_ == 'aers':
                _data.write('$')
            if type_ == 'faers':
                _data.write('$')
            _data.write(filename)

            _data.write('\n')
        data = _data.getvalue()
        _data.close()

    # remove empty line at the end
    if data[-1] == '\n':
        data = data[:-1]

    # demo
    # fix problem data record - remove embedded $ field separator in string
    if data_type == 'demo' and year == '2012' and quarter == '1':
        data = data.replace(
            '8129732$8401177$I$$8129732-9$20120126$20120206$20120210$EXP$JP-CUBIST-$E2B0000000182$CUBIST PHARMACEUTICALS, INC.$85$YR$M$Y$$$20120210$PH$$$$JAPAN$DEMO12Q1.TXT',
            '8129732$8401177$I$$8129732-9$20120126$20120206$20120210$EXP$JP-CUBIST-E2B0000000182$CUBIST PHARMACEUTICALS, INC.$85$YR$M$Y$$$20120210$PH$$$$JAPAN$DEMO12Q1.TXT'
        )

    # drug
    # fix 4 remaining problem data records
    if data_type == 'drug' and year == '2010' and quarter == '1':
        data.replace(
            '6750381$1013798159$SS$MORPHINE SULFATE$1$ORAL$30 MG, TID, ORAL$D$D$$$$6750381$1013798165$C$KADIAN$1$$$$$$$$DRUG10Q2.TXT',
            '6750381$1013798159$SS$MORPHINE SULFATE$1$ORAL$30 MG, TID, ORAL$D$D$$$$DRUG10Q2.TXT\n6750381$1013798165$C$KADIAN$1$$$$$$$$DRUG10Q2.TXT'
        )
    if data_type == 'drug' and year == '2011' and quarter == '2':
        data.replace(
            '7475791$1016572490$SS$DOXORUBICIN (DOXORUBICIN) (INJECTION)$2$INTRAVENOUS$25 MG\/M2 MILLIGRAM(S)\/SQ. METER, DAY 1 AND 15, EVERY 28 DAYS, INTRAVENOUS (NOT OTHERWISE SPECIFIED)$$$$$$7475791$1016572486$SS$PROCARBAZINE HYDROCHLORIDE$1$ORAL$40 MG\/M2 MILLIGRAMS(S)\/SQ. METER, DAY 1-14, ORAL$$$$$$DRUG11Q2.TXT',
            '7475791$1016572490$SS$DOXORUBICIN (DOXORUBICIN) (INJECTION)$2$INTRAVENOUS$25 MG\/M2 MILLIGRAM(S)\/SQ. METER, DAY 1 AND 15, EVERY 28 DAYS, INTRAVENOUS (NOT OTHERWISE SPECIFIED)$$$$$$DRUG11Q2.TXT\n7475791$1016572486$SS$PROCARBAZINE HYDROCHLORIDE$1$ORAL$40 MG\/M2 MILLIGRAMS(S)\/SQ. METER, DAY 1-14, ORAL$$$$$$DRUG11Q2.TXT'
        )
    if data_type == 'drug' and year == '2011' and quarter == '3':
        data.replace(
            '7652730$1017255397$SS$BEVACIZUMAB (RHUMAB VEGF)$2$$920 MG$$$$$$7652731$1017185840$PS$DYSPORT$1$INTRAMUSCULAR$150 UNITS (150 UNITS, SINGLE CYCLE), INTRAMUSCULAR$N$D$825C$$$DRUG11Q3.TXT',
            '7652730$1017255397$SS$BEVACIZUMAB (RHUMAB VEGF)$2$$920 MG$$$$$$DRUG11Q3.TXT\n7652731$1017185840$PS$DYSPORT$1$INTRAMUSCULAR$150 UNITS (150 UNITS, SINGLE CYCLE), INTRAMUSCULAR$N$D$825C$$$DRUG11Q3.TXT'
        )
    if data_type == 'drug' and year == '2011' and quarter == '4':
        data.replace(
            '7941354$1018188213$SS$MEMANTINE HYDROCHLORIDE$1$ORAL$15 MG (15 MG, 1 IN 1 D),ORAL$D$D$$$$7941355$1018142414$SS$DROSPIRENONE AND ETHINYL ESTRADIOL$1$$UNK$$$93657A$$021098$DRUG11Q4.TXT',
            '7941354$1018188213$SS$MEMANTINE HYDROCHLORIDE$1$ORAL$15 MG (15 MG, 1 IN 1 D),ORAL$D$D$$$$DRUG11Q4.TXT\n7941355$1018142414$SS$DROSPIRENONE AND ETHINYL ESTRADIOL$1$$UNK$$$93657A$$021098$DRUG11Q4.TXT'
        )

    return data
