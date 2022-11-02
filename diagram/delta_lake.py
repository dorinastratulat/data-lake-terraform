from diagrams import Diagram, Cluster
from diagrams.custom import Custom
from diagrams.aws.database import RDSSqlServerInstance, DatabaseMigrationService
from diagrams.aws.storage import SimpleStorageServiceS3
from diagrams.aws.analytics import Glue, Redshift

with Diagram(
    "SQL Server to Delta Lake",
    "diagram/delta_lake",
    outformat="png",
    show=False,
):

    with Cluster("AWS"):
        sql_server = RDSSqlServerInstance("RDS")

        with Cluster("Stage 1"):
            dms = DatabaseMigrationService("DMS")
            bucket = SimpleStorageServiceS3("Storage Bucket")

        sql_server >> dms >> bucket
        dms >> sql_server

        with Cluster("Stage 2"):
            glue = Glue("S3 to Delta Lake")
            delta = Custom("Delta Lake", "./resources/delta-lake.png")

        bucket >> glue >> delta

        with Cluster("Stage 3"):
            glue_2 = Glue("Delta to Redshift")
            redshift = Redshift("Redshift")

        delta >> glue_2 >> redshift
