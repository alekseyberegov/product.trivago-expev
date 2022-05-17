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
    tunnel: SecureTunnel = SecureTunnel(
        ssh_user = str(ctx.config('proxy', 'ssh_user')),
        ssh_host = str(ctx.config('proxy', 'ssh_host')),
        ssh_port = int(ctx.config('proxy', 'ssh_port')),
        ssh_bind = int(ctx.config('proxy', 'ssh_bind')),
        ssh_pkey = str(ctx.asfile('proxy', 'ssh_pkey')),
        host = str(ctx.config('database', 'host')),
        port = int(ctx.config('database', 'port'))
    )
    tunnel.start()
    tunnel.stop()