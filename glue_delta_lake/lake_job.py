import os
import sys

try:
    from awsglue.context import GlueContext
    from awsglue.dynamicframe import DynamicFrame
    from awsglue.job import Job
    from awsglue.utils import getResolvedOptions

    # from awsglue.transforms import *
except ImportError:
    raise ImportError("Please run script in a Glue job to import Glue libraries")

try:
    from delta import DeltaTable
except ImportError:
    raise ImportError(
        "Please install the Delta Core library. If you're using a Glue job, add your delta-core_*.jar "
        "to both JAR paths and Python paths in the job config."
    )

from pyspark.conf import SparkConf
from pyspark.context import SparkContext
from pyspark.sql import SparkSession, DataFrame

GLUE_CUSTOM_PARAMS = [
    "table_name",
    "raw_zone_path",
    "structured_zone_path",
    "merge_key",
    "full_load",
]


def validate_custom_params(args):
    """Validate custom parameters for Glue job"""
    if not all([param in sys.argv for param in args]):
        raise ValueError(
            "Missing required parameters. Please check your Glue job configuration."
        )


class LakeJob:
    """Manager utility class for data lake jobs in AWS"""

    _delta_lake_config = {
        # uncomment if not using Glue
        # "spark.jars.packages": "io.delta:delta-core_2.12:1.0.1",
        "spark.sql.extensions": "io.delta.sql.DeltaSparkSessionExtension",
        "spark.sql.catalog.spark_catalog": "org.apache.spark.sql.delta.catalog.DeltaCatalog",
    }

    __read_options = {"csv": {"header": True}}

    def __init__(self):
        self._spark_conf = SparkConf()
        map(
            lambda k, v: self._spark_conf.set(k, v),
            self._delta_lake_config.items(),
        )

        validate_custom_params(GLUE_CUSTOM_PARAMS)
        self._args = getResolvedOptions(sys.argv, ["JOB_NAME", *GLUE_CUSTOM_PARAMS])

        # destructure args
        self.table_name = self._args["table_name"]
        self.rz_path = self._args["raw_zone_path"]
        self.sz_path = self._args["structured_zone_path"]
        self.merge_key = self._args["merge_key"]
        self.full_load = True if self._args["full_load"] is not None else False

        self._sc = SparkContext()
        self._glue_context = GlueContext(self._sc)
        self.job = Job(self._glue_context)

        builder = SparkSession.builder.config(conf=self._spark_conf)

        # self.spark = configure_spark_with_delta_pip(builder).getOrCreate()
        self.spark = builder.getOrCreate()

        # init job
        self.job.init(self._args["JOB_NAME"], self._args)

    def run(self):
        self.load_table()
        self.load_cdc()

    def commit(self):
        self.job.commit()

    def load_table(self, force=False, format="parquet"):
        """Load table from path"""
        table_path = os.path.join(self.sz_path, self.table_name)
        raw_path = os.path.join(self.rz_path, self.table_name)

        if not DeltaTable.isDeltaTable(self.spark, table_path) or force:
            print("Table does not exist. Creating table...")
            _ = (
                self.spark.read.format(format)
                .load(raw_path)
                .write.format("delta")
                .save(table_path)
            )

        self.table = DeltaTable.forPath(self.spark, table_path)
        self.table.generate("symlink_format_manifest")

    def load_cdc(self):
        """Load CDC data from path"""

        cdc_path = os.path.join(self.rz_path, self.table_name, "updates")
        df: DataFrame = self._glue_context.create_dynamic_frame.from_options(
            connection_type="s3",
            connection_options={
                "paths": [cdc_path],
                "recurse": True,
            },
        )

        if df.count() == 0:
            print("No CDC data found. Skipping...")
            return

        if "operation" not in df.columns and len(df.columns) != 2:
            raise ValueError("CDC data must have an operation column")

        upserts_df = df.filter("operation <> 'delete'")
        deletes_df = df.filter("operation = 'delete'")

        # parse the data column into a df
        upserts_df = upserts_df.selectExpr("data.*")
        deletes_df = deletes_df.selectExpr("data.*")

        if upserts_df.count() > 0:
            self.table.alias("t").merge(
                upserts_df.toDF().alias("u"),
                f"t.{self.merge_key} = u.{self.merge_key}",
            ).whenMatchedUpdateAll().whenNotMatchedInsertAll().execute()

        if deletes_df.count() > 0:
            self.table.alias("t").merge(
                deletes_df.toDF().alias("d"),
                f"t.{self.merge_key} = d.{self.merge_key}",
            ).whenMatchedDelete().execute()


if __name__ == "__main__":
    j = LakeJob()
    j.run()
    j.commit()
