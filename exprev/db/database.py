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
            kwargs['driver' ], '://',
            kwargs['user'   ], ':',
            kwargs['passwd' ], '@',
            kwargs['host'   ], ':',
            kwargs['port'   ], '/',
            kwargs['database']
        ])

class Database:
    def __init__(self, **kwargs) -> None:
        self.__driver = kwargs.get('driver')
        self.__user = kwargs.get('user')
        self.__passwd = kwargs.get('passwd')
        self.__database = kwargs.get('database')
        self.__host = kwargs.get('host')
        self.__port = kwargs.get('port')

    @property
    def database(self) -> str:
        return self.__database

    @property
    def user(self) -> str:
        return self.__user

    @property
    def driver(self) -> str:
        return self.__driver

    def mount(self, proxy: Proxy = None, url: DatabaseUrl = None) -> 'Database':
        self.__proxy: Proxy = proxy
        connect_props = vars(self)

        if proxy is not None:
            proxy.start()
            connect_props['host'] = proxy.get_host()
            connect_props['port'] = proxy.get_port()

        if url is None:
            url = DefaultDatabaseUrl()
        
        self.__engine = create_engine(url.build(**connect_props))
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