import pytest
from  exprev.db.connection import Connection

@pytest.fixture
def con() -> Connection:
    return Connection(user='auser', paswd='secret', database='mydb', host='local', port=123)

class TestConnection(object):
    def test_database(self, con: Connection) -> None:
        assert con.database == 'mydb'
        assert con.user == 'auser'

