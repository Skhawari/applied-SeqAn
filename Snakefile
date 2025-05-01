import os

# Configurable input directory
input_dir = "data/tiny"

# Automatically detect all SAM files (ending in .sam)
SAMPLES = [f.replace(".sam", "") for f in os.listdir(input_dir) if f.endswith(".sam")]

rule all:
    input:
        expand("results/stats/{sample}.idxstats.txt", sample=SAMPLES)

rule sam_to_bam:
    input:
        lambda wildcards: f"{input_dir}/{wildcards.sample}.sam"
    output:
        "results/bam/{sample}.bam"
    shell:
        "mkdir -p results/bam && samtools view -Sb {input} > {output}"

rule sort_bam:
    input:
        "results/bam/{sample}.bam"
    output:
        "results/bam_sorted/{sample}.sorted.bam"
    shell:
        "mkdir -p results/bam_sorted && samtools sort -o {output} {input}"

rule index_bam:
    input:
        "results/bam_sorted/{sample}.sorted.bam"
    output:
        "results/bam_sorted/{sample}.sorted.bam.bai"
    shell:
        "samtools index {input}"

rule idxstats:
    input:
        bam="results/bam_sorted/{sample}.sorted.bam",
        bai="results/bam_sorted/{sample}.sorted.bam.bai"
    output:
        "results/stats/{sample}.idxstats.txt"
    shell:
        "mkdir -p results/stats && samtools idxstats {input.bam} > {output}"
