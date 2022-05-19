import click

from exprev.cli.cli import pass_environment, Environment
from exprev.db.client import Client
from exprev.db.resultset import RecordCollection
from exprev.utils.template import render_template

@click.command("database", short_help="run SQL script")
@click.argument("sqlfile", type=click.Path(exists=True))
@click.option('--param',  multiple=True, type=(str, str))
@pass_environment
def cli(ctx: Environment, sqlfile, param):
    sql_params = {}
    if param is not None:
        for name, value in param:
            sql_params[name] = value

    df = Client.read_database(ctx.config_parser(), sqlfile, sql_params);
    print (df)




