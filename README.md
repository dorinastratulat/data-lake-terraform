# Data Lake Terraform

## Intro

This repository contains two (WIP) PoC implementations of a Data Lake on AWS using Terraform. At a high level, the flow is as follows:

1. [Amazon RDS for SQL Server](https://aws.amazon.com/rds/sqlserver/)
2. [AWS DMS](https://aws.amazon.com/dms/)
3. [AWS Glue](https://aws.amazon.com/glue/)
4. [Delta Lake](https://delta.io) OR [Apache Iceberg](https://iceberg.apache.org)
5. Glue Crawler
6. Redshift & Redshift Spectrum

## Getting started

Ensure you have the [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured with your AWS credentials.

**NOTE:** At the moment, neither of these implementations work.

**[Delta Lake:](./tf_delta_lake/)**

```bash
# clone the repository
git clone https://github.com/zhooda/data-lake-terraform.git
# change into the delta lake directory
cd data-lake-terraform/tf_delta_lake
# initialize terraform
terraform init
# plan
terraform plan
# apply
terraform apply
# destroy 
terraform destroy
```

**[Apache Iceberg:](./tf_iceberg/)**

```bash
# clone the repository
git clone   
# change into the iceberg directory
cd data-lake-terraform/tf_iceberg
# initialize terraform
terraform init
# plan
terraform plan
# apply
terraform apply
# destroy
terraform destroy
```

## Resources

https://docs.delta.io/latest/index.html 
https://blog.bandowski.eu/using-delta-lake-within-aws-glue-jobs-c3539a6d74e2
https://blog.devgenius.io/modern-data-stack-demo-5d75dcdfba50
https://www.terraform-best-practices.com/examples/terraform/small-size-infrastructure