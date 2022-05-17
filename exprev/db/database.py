import abc
from sqlalchemy import create_engine
from exprev.net.proxy import Proxy
from exprev.db.connection import Connection

class DatabaseUrl(abc.ABC):
    @abc.abstractmethod
    def build(self, **kwargs) -> str:
        pass

class DefaultDatabaseUrl(DatabaseUrl):
    def build(self, **kwargs) -> str:
        return "".join([
            str(kwargs['driver'  ]), '://',
            str(kwargs['user'    ]), ':',
            str(kwargs['passwd'  ]), '@',
            str(kwargs['host'    ]), ':',
            str(kwargs['port'    ]), '/',
            str(kwargs['database'])
        ])

class Database:
    def __init__(self, **kwargs) -> None:
        self.__db_props = dict(kwargs)

    @property
    def database(self) -> str:
        return self.__db_props['database']

    @property
    def user(self) -> str:
        return self.__db_props['user']

    @property
    def driver(self) -> str:
        return self.__db_props['driver']
   
    def mount(self, proxy: Proxy = None, url: DatabaseUrl = None) -> 'Database':
        self.__proxy: Proxy = proxy
        props = dict(self.__db_props)

        if proxy is not None:
            proxy.start()
            props['host'] = proxy.get_host()
            props['port'] = proxy.get_port()

        if url is None:
            url = DefaultDatabaseUrl()
        
        self.__engine = create_engine(url.build(**props))
        self.__open = True

        return self

    def connect(self) -> Connection:
        if not self.__open:
            return None

        return Connection(self.__engine.connect())

    def unmount(self) -> None:
        if self.__proxy is not None:
            self.__proxy.stop()
        if self.__open:
            self.__engine.dispose()
            self.__open = False