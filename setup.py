__author__ = 'Guillaume Taglang <guillaume@asthea.com>'

from setuptools import find_packages
from setuptools import setup

setup(
    name='faersdbstats',
    version='0.0.1',

    description='FAERS data import',
    author='Guillaume Taglang',
    author_email='guillaume@asthea.com',

    packages=find_packages('src/py'),
    package_dir={'': 'src/py'},
    package_data={'': ['*.sql']},

    entry_points={
        'console_scripts': [
            'faersdbstats = asthea.faersdbstats.cli:main',
        ],
    },

    install_requires=[
        'beautifulsoup4',
        'Click', 'click_log',
        'psycopg2',
        'requests'
    ],

    zip_safe=True
)
