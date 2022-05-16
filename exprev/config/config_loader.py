import configparser, os
from os.path import exists, expanduser, join

class ConfigLoader:
    def __init__(self, name: str) -> None:
        files = []
        for loc in os.curdir, expanduser("~"), os.environ.get("EXPREV_CONF", "/etc"):
            file = join(loc, name)
            if exists(file):
                files.append(file)

        self.__config = configparser.ConfigParser()
        if len(files) > 0:
            self.__config.read(files)

    def config(self):
        return self.__config
