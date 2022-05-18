import click, json, os

from exprev.cli.cli import pass_environment, Environment
from exprev.db.database import Database
from exprev.db.resultset import RecordCollection, Record
from exprev.net.sshtunnel import SecureTunnel
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

    with open(sqlfile, 'r') as fd:
        query = fd.read()

    dbhost: str = str(ctx.config('database', 'host'))
    dbport: int = int(ctx.config('database', 'port'))

    tunnel: SecureTunnel = SecureTunnel(
        ssh_user = str(ctx.config('proxy', 'ssh_user')),
        ssh_host = str(ctx.config('proxy', 'ssh_host')),
        ssh_port = int(ctx.config('proxy', 'ssh_port')),
        ssh_bind = int(ctx.config('proxy', 'ssh_bind')),
        ssh_pkey = str(ctx.asfile('proxy', 'ssh_pkey')),
        host = dbhost,
        port = dbport
    )

    database: Database = Database(
        user     = ctx.config('database', 'user'),
        passwd   = ctx.config('database', 'passwd'),
        driver   = ctx.config('database', 'driver'),
        database = ctx.config('database', 'database'),
        host     = dbhost,
        port     = dbport
    )

    database.mount(tunnel)
    try:
        with database.connect() as dbcon:
            records: RecordCollection = dbcon.query(render_template(query, sql_params));
            df = records.export('df');
            print(df)
    finally:
        database.unmount()



