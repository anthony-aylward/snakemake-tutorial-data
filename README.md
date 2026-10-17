[![Gitpod Ready-to-Code](https://img.shields.io/badge/Gitpod-ready--to--code-blue?logo=gitpod)](https://gitpod.io/#https://github.com/snakemake/snakemake-tutorial-data)

# Example data for the Snakemake tutorial

This repository hosts the data needed for the [Snakemake tutorial](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html).

---

This fork adds the `plot-quals.py` script from the tutorial, and a modified version of the [tutorial](https://snakemake.readthedocs.io/en/stable/tutorial/tutorial.html) `snakefile`. This snakefile makes the following changes:
* Adds a `conda: "environment.yaml"` parameter to each rule, so the workflow can be run without creating an external workflow-specific conda environment.
* Includes the FASTA index for BWA in the input defenition for the `bwa_map` rule, as otherwise the index will be missing and cause a non-local run to fail.
* Placess all output files within a single directory `output/`, for easier clean up after a test run.

## Clone repository

To start, clone this repository and navigate into it:

```sh
git clone https://github.com/anthony-aylward/snakemake-tutorial-data.git
cd snakemake-tutorial-data
```

## Local run

Conda environment for Snakemake:

```sh
conda create --name snake-local --yes snakemake
conda activate snake-local
```

Dry run:

```sh
snakemake -n --sdm conda --jobs 4 --snakefile snakefile
```

Local run:

```sh
snakemake --sdm conda --jobs 4 --snakefile snakefile
```

## Local run with data stored on  AWS S3

```sh
conda create --name snake-s3 --yes snakemake snakemake-storage-plugin-s3
conda activate snake-s3
```

Check the data on S3:
```sh
aws s3 ls s3://<bucket>/snakemake-tutorial-data/
```

```sh
snakemake --sdm conda  --jobs 4 \
    --default-storage-provider s3 \
    --default-storage-prefix s3://<bucket>/snakemake-tutorial-data/ \
    --snakefile snakefile
```

Clean up the results:
```sh
aws s3 rm --recursive s3://<bucket>/snakemake-tutorial-data/output/
```

## Remote run via AWS Batch with data stored on AWS S3

```sh
conda create --name snake --yes \
  snakemake snakemake-storage-plugin-s3 snakemake-executor-plugin-aws-batch
conda activate snake
```

```sh
snakemake --sdm conda  --jobs 4 \
    --executor aws-batch \
    --aws-batch-region <region> \
    --aws-batch-job-queue "<arn:aws:batch:...>" \
    --aws-batch-job-role "<arn:aws:iam::...>" \
    --default-storage-provider s3 \
    --default-storage-prefix s3://<bucket>/snakemake-tutorial-data/ \
    --snakefile snakefile
```

Clean up the results:
```sh
aws s3 rm --recursive s3://<bucket>/snakemake-tutorial-data/output/
```
