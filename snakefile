SAMPLES = ["A", "B"]


rule all:
    input:
        "output/plots/quals.svg"


rule bwa_map:
    conda: "environment.yaml"
    threads: 2
    resources: mem_mb=16_384
    input:
        genome="data/genome.fa",
        reads="data/samples/{sample}.fastq",
        index=["data/genome.fa.amb",
               "data/genome.fa.ann",
               "data/genome.fa.bwt",
               "data/genome.fa.fai",
               "data/genome.fa.pac",
               "data/genome.fa.sa"]
    output:
        "output/mapped_reads/{sample}.bam"
    shell:
        "bwa mem {input.genome} {input.reads} | samtools view -Sb - > {output}"


rule samtools_sort:
    conda: "environment.yaml"
    input:
        "output/mapped_reads/{sample}.bam"
    output:
        "output/sorted_reads/{sample}.bam"
    shell:
        "samtools sort -T output/sorted_reads/{wildcards.sample} "
        "-O bam {input} > {output}"


rule samtools_index:
    conda: "environment.yaml"
    input:
        "output/sorted_reads/{sample}.bam"
    output:
        "output/sorted_reads/{sample}.bam.bai"
    shell:
        "samtools index {input}"


rule bcftools_call:
    conda: "environment.yaml"
    input:
        fa="data/genome.fa",
        bam=expand("output/sorted_reads/{sample}.bam", sample=SAMPLES),
        bai=expand("output/sorted_reads/{sample}.bam.bai", sample=SAMPLES)
    output:
        "output/calls/all.vcf"
    shell:
        "bcftools mpileup -f {input.fa} {input.bam} | "
        "bcftools call -mv - > {output}"


rule plot_quals:
    conda: "environment.yaml"
    input:
        "output/calls/all.vcf"
    output:
        "output/plots/quals.svg"
    script:
        "scripts/plot-quals.py"
