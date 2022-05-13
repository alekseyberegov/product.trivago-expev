
class Connection:
    def __init__(self, **kwargs) -> None:
        self.__user = kwargs['user']
        self.__paswd = kwargs['paswd']
        self.__database = kwargs['database']
        self.__host = kwargs['host']
        self.__port = kwargs['port']

    @property
    def database(self) -> str:
        return self.__database

    @property
    def user(self) -> str:
        return self.__user