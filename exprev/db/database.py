import abc
from sqlalchemy import create_engine
from exprev.db.proxy import Proxy

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

    def open(self, proxy: Proxy = None, url: DatabaseUrl = None) -> None:
        self.__proxy: Proxy = proxy
        
        if proxy is not None:
            proxy.start()

        if url is None:
            url = DefaultDatabaseUrl()
        
        kwargs = vars(self)
        self.__engine = create_engine(url.build(**kwargs))
        self.__open = True

    def close(self) -> None:
        if self.__proxy is not None:
            self.__proxy.stop()
        if self.__open:
            self.__engine.dispose()