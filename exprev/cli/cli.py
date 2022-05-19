import os
import sys
import click
import json

from typing import Dict
from os.path import exists, expanduser, join

from exprev.config.config_loader import ConfigLoader

CONTEXT_SETTINGS = dict(auto_envvar_prefix="exprev")

class Environment:
    def __init__(self):
        self.verbose = False
        self.home = os.getcwd()
        self.__config = (ConfigLoader("exprev.ini")).config()

    def config_parser(self):
        return self.__config
        
    def config(self, section: str, option: str) -> str:
        return self.__config.get(section, option)

    def asfile(self, section: str, option: str) -> str:
        return os.path.expanduser(self.config(section, option))

    def log(self, msg, *args):
        """Logs a message to stderr."""
        if args:
            msg %= args
        click.echo(msg, file=sys.stderr)

    def vlog(self, msg, *args):
        """Logs a message to stderr only if verbose is enabled."""
        if self.verbose:
            self.log(msg, *args)

pass_environment = click.make_pass_decorator(Environment, ensure=True)
cmd_folder = os.path.abspath(os.path.join(os.path.dirname(__file__), "commands"))

class ExpRevCLI(click.MultiCommand):
    def list_commands(self, ctx):
        cmds = []
        for filename in os.listdir(cmd_folder):
            if filename.endswith(".py") and filename.startswith("cmd_"):
                cmds.append(filename[4:-3])
        cmds.sort()
        return cmds

    def get_command(self, ctx, name):
        try:
            pkg = 'exprev.cli.commands'
            mod = __import__(f"{pkg}.cmd_{name}", None, None, ["cli"])
        except ImportError as e:
            return None
        return mod.cli


@click.command(cls=ExpRevCLI, context_settings=CONTEXT_SETTINGS)
@click.option(
    "--home",
    type=click.Path(exists=True, file_okay=False, resolve_path=True),
    help="Changes the folder to operate on.",
)
@click.option("-v", "--verbose", is_flag=True, help="Enables verbose mode.")
@pass_environment
def cli(ctx, verbose, home):
    """exprev command line interface."""
    ctx.verbose = verbose
    if home is not None:
        ctx.home = home

if __name__ == '__main__':
    cli()