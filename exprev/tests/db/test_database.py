import pytest
from typing import Dict
from  exprev.db.database import Database

@pytest.fixture
def db_config() -> Dict:
    return {
        'driver'    : 'dummy',
        'user'      : 'john',
        'passwd'    : 'secret',
        'database'  : 'data',
        'host'      : 'local',
        'port'      : '12345'
    }

@pytest.fixture
def db_inst(db_config: Dict) -> Database:
    return Database(**db_config)

class TestDatabase(object):
    def test_database(self, db_inst: Database) -> None:
        assert db_inst.database == 'data'
        assert db_inst.user == 'john'
        assert db_inst.driver == 'dummy'