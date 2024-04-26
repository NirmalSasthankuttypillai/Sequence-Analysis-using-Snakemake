import os

# input directory containing SAM files
SAM_DIR = "/Users/nirmalsv/Documents/ASA/sam_tiny"

#output directory for BAM files
BAM_DIR = "/Users/nirmalsv/Documents/ASA"

# Listing all SAM files in the directory
SAM_FILES = glob_wildcards(os.path.join(SAM_DIR, "{id}.sam")).id


# Defining a rule that collects all target BAM files, stats files, and BAM index files
rule all:
    input:
        expand(os.path.join(BAM_DIR, "bam_sorted", "{id}.bam"), id=SAM_FILES),
        expand(os.path.join(BAM_DIR, "stats", "{id}.txt"), id=SAM_FILES),
        expand(os.path.join(BAM_DIR, "bam_sorted", "{id}.bam.bai"), id=SAM_FILES)

# SAM to BAM
rule sam_to_bam:
    input:  os.path.join(SAM_DIR, "{id}.sam")
    output: os.path.join(BAM_DIR, "bam", "{id}.bam")
    shell:  "samtools view -bS {input} > {output}"

# sorting BAM files
rule sort_bam:
    input:  os.path.join(BAM_DIR, "bam", "{id}.bam")
    output: os.path.join(BAM_DIR, "bam_sorted", "{id}.bam")
    shell:  "samtools sort -o {output} {input}"

# Indexing BAM files
rule index_bam:
    input:  os.path.join(BAM_DIR, "bam_sorted", "{id}.bam")
    output: os.path.join(BAM_DIR, "bam_sorted", "{id}.bam.bai")
    shell:  "samtools index {input}"

# Calculating mapping stats
rule mapping_stats:
    input:  os.path.join(BAM_DIR, "bam_sorted", "{id}.bam")
    input:  os.path.join(BAM_DIR, "bam_sorted", "{id}.bam.bai")
    output: os.path.join(BAM_DIR, "stats", "{id}.txt")
    shell:  "samtools idxstats {input} > {output}"
