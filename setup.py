from setuptools import setup, find_packages

setup(
    name='exprev',
    version='0.1.0',
    packages=find_packages(include=['exprev', 'exprev.*']),
    description='Expected Revenue Analytics',
    author='Aleksey Beregov',
    install_requires=[
        'SQLAlchemy==1.4.36',
        'tablib==3.2.1',
        'paramiko==2.10.4',
        'sshtunnel==0.4.0',
        'sycopg2-binary==2.9.3',
        'pandas==1.4.2',
        'numpy==1.22.3'
    ],
    setup_requires=['pytest-runner'],
    tests_require=['pytest']
)



