from setuptools import setup, find_packages

setup(
    name='exprev',
    version='0.1.0',
    packages=find_packages(include=['exprev', 'exprev.*']),
    description='Expected Revenue Analytics',
    author='Aleksey Beregov',
    install_requires=[
        'SQLAlchemy==1.4.36'
    ],
    tests_require=['pytest']
)



