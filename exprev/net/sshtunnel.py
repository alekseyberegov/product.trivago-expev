import paramiko
import io
from sshtunnel import SSHTunnelForwarder
from exprev.net.proxy import Proxy

class SecureTunnel(Proxy):
    def __init__(self, **kwargs) -> None:
        self.__local_port = kwargs['ssh_bind']
        self.__local_host = 'localhost'

        self.__tunnel: SSHTunnelForwarder = SSHTunnelForwarder(
            (kwargs['ssh_host'], kwargs['ssh_port']),
            ssh_username=kwargs['ssh_user'],
            ssh_pkey=kwargs['ssh_pkey'],
            local_bind_address=(self.__local_host, self.__local_port),
            remote_bind_address=(kwargs['host'], kwargs['port'])
        )

    def start(self) -> None:
        self.__tunnel.start()

    def stop(self) -> None:
        self.__tunnel.close()

    def get_host(self) -> str:
        return self.__local_host
    
    def get_port(self) -> int:
        return self.__local_port
