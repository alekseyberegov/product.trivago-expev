from typing import Dict
from configparser import ConfigParser
from exprev.net.sshtunnel import SecureTunnel
from exprev.db.database import Database
from exprev.db.resultset import RecordCollection
from exprev.utils.template import render_template

class Client:
    config_map = {
        'host'    : ['database' , 'host'     , lambda v: v      ],
        'port'    : ['database' , 'port'     , lambda v: int(v) ],
        'user'    : ['database' , 'user'     , lambda v: v      ],
        'passwd'  : ['database' , 'passwd'   , lambda v: v      ],
        'driver'  : ['database' , 'driver'   , lambda v: v      ],
        'database': ['database' , 'name'     , lambda v: v      ],
        'ssh_host': ['proxy'    , 'ssh_host' , lambda v: v      ],
        'ssh_user': ['proxy'    , 'ssh_user' , lambda v: v      ],
        'ssh_port': ['proxy'    , 'ssh_port' , lambda v: int(v) ],
        'ssh_bind': ['proxy'    , 'ssh_bind' , lambda v: int(v) ],
        'ssh_pkey': ['proxy'    , 'ssh_pkey' , lambda v: v      ],
    }

    def __init__(self, config: ConfigParser):
        self.__props: Dict  = {}
        for name, conf in self.config_map.items():
            section = conf[0]
            if section in config and conf[1] in config[section]:
                self.__props[name] = conf[2](config[section][conf[1]]);

    def __enter__(self):
        self.__database: Database = Database(**self.__props)
        self.__database.mount(proxy = SecureTunnel(**self.__props) if 'ssh_host' in self.__props else None)
        return self.__database

    def __exit__(self, exc_type, exc_value, exc_traceback):
        self.__database.unmount()

    @staticmethod
    def read_database(config: ConfigParser, file, params = {}):
        with open(file, 'r') as fd:
            sql_query = fd.read()
            with Client(config) as db:
                with db.connect() as con:
                    records: RecordCollection = con.query(render_template(sql_query, params));
                    return records.export('df');