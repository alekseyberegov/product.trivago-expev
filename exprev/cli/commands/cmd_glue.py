import json
import click
import awswrangler
import pandas
import boto3

from exprev.cli.cli import pass_environment, Environment

@click.command("glue", short_help="manage datasets using S3/Glue/Athena")
@click.argument("jsonfile", type=click.Path(exists=True))
@click.option('--table',  type=str, required=True, help="the table name")
@click.option('--partition',  type=str, multiple=True)
@click.option("--mode", type=click.Choice(['append', 'overwrite_partitions', 'overwrite']), 
    show_default=True, default="overwrite_partitions", help="the data overwite mode")
@pass_environment
def cli(ctx: Environment, jsonfile, table: str, partition, mode:str):
    boto3.setup_default_session(region_name="us-west-2")

    with open(jsonfile, 'r') as fd:
        json_str = fd.read()

    df = pandas.DataFrame(json.loads(json_str))
    # TODO: make a backup and cut a new version
    awswrangler.s3.to_parquet(
        df = df,
        path = ctx.config('s3', 'product_adm'),
        dataset = True,
        mode = mode,
        partition_cols = partition if len(partition) > 0 else None,
        database = ctx.config('glue', 'database'),
        table = table
    )

