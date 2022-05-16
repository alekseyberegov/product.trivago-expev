import abc

class Proxy(abc.ABC):
    @abc.abstractmethod
    def get_port(self) -> int:
        pass

    @abc.abstractmethod
    def get_host(self) -> str:
        pass

    @abc.abstractmethod
    def start(self) -> None:
        pass

    @abc.abstractmethod
    def stop(self) -> None:
        pass
