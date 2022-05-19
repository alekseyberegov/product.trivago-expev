import functools
import click
import awswrangler
import pandas
import boto3

from exprev.cli.cli import pass_environment, Environment
from exprev.db.client import Client

@click.command("glue", short_help="manage datasets using S3/Glue/Athena")
@click.argument("file", type=click.Path(exists=True))
@click.option("--format", type=click.Choice(['json', 'csv', 'sql']), show_default=True, default="json", help="the file format")
@click.option('--table',  type=str, required=True, help="the table name")
@click.option('--partition',  type=str, multiple=True)
@click.option('--param',  multiple=True, type=(str, str))
@click.option("--mode", type=click.Choice(['append', 'overwrite_partitions', 'overwrite']), 
    show_default=True, default="overwrite_partitions", help="the data overwite mode")
@pass_environment
def cli(ctx: Environment, file, format:str, table: str, partition:str, param, mode:str):
    boto3.setup_default_session(region_name="us-west-2")

    sql_params = {}
    if param is not None:
        for name, value in param:
            sql_params[name] = value

    config = ctx.config_parser()

    df = {
        'json': functools.partial(pandas.read_json,file, **{'typ':'frame','orient':'columns'}),
        'csv' : functools.partial(pandas.read_csv ,file),
        'sql' : functools.partial(Client.read_database, config, file, sql_params)
    }[format]()

    folder = ctx.config('s3', 'product_adm')

    awswrangler.s3.to_parquet(
        df = df,
        path = f"{folder}{table}",
        dataset = True,
        mode = mode,
        partition_cols = partition if len(partition) > 0 else None,
        database = ctx.config('glue', 'database'),
        table = table,
        dtype={'date': 'string', 'crunch_date': 'string', 'partition_date': 'string'}
    )

