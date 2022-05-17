import click, json, os

from exprev.cli.cli import pass_environment, Environment
from exprev.db.database import Database
from exprev.net.sshtunnel import SecureTunnel

@click.command("database", short_help="run SQL query")
@click.argument("query")
@click.option('--user')
@click.option('--passwd')
@pass_environment
def cli(ctx: Environment, query, user, passwd):
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
    database.unmount()



