import paramiko
import io
from sshtunnel import SSHTunnelForwarder
from exprev.net.proxy import Proxy

class SshTunnel(Proxy):
    def __init__(self, **kwargs) -> None:
        self.__ssh_port = kwargs['ssh_port']
        self.__ssh_host = kwargs['ssh_host']

        with open(kwargs['ssh_file'], 'r') as file:
            content = file.read()
            ssh_pkey = paramiko.RSAKey.from_private_key(io.StringIO(content))

        self.__tunnel = SSHTunnelForwarder(
            ssh_username=kwargs['ssh_user'],
            ssh_pkey=ssh_pkey,
            ssh_host=(self.__ssh_host, self.__ssh_port),
            remote_bind_address=(kwargs['host'], kwargs['port'])
        )

    def start(self) -> None:
        self.__tunnel.start()

    def stop(self) -> None:
        self.__tunnel.close()

    def get_host(self) -> str:
        return self.__ssh_host
    
    def get_port(self) -> int:
        return self.__ssh_port
