Here is a Snakemake workflow for NGS RNA sequencing quantification using salmon

```
import pandas as pd
import urllib.request
import hashlib

# input is a csv file obtained from and containing filtered data from the SRA database
# this can be modified if files are local and do not need to be downloaded
SRA_df=pd.read_csv("SRA_accessions_filtered.csv")
sample_list=list(SRA_df['Run'])

rule all:
    input:
        expand("infofiles/{sample}.info", sample = sample_list),
        expand("fastq_files/{sample}_1.fastq.gz", sample = sample_list),
        expand("fastq_files/{sample}_2.fastq.gz", sample = sample_list),
        expand("fastq_files/{sample}_1.fastq",sample = sample_list),
        expand("fastq_files/{sample}_2.fastq",sample = sample_list),
        "genome/GCF_001593425.2_ASM159342v2_genomic.gbff.gz",
        "genome/GCF_001593425.2_ASM159342v2_genomic.gbff",
        "salmon_indexing_done",
        "genome/GCF_001593425.2_ASM159342v2_genomic_transcripts.fasta",
        expand("{sample}_quant/quant.sf",sample = sample_list)

# Obtaining files from the ebi website is much faster than NCBI since the fastq.gz files can be directly downloaded instead of an intermediate filetype
# first the info files are downloaded which contain the paths to download the read files
rule download_infofiles:
    output:"infofiles/{sample}.info"
    run:
        url= "https://www.ebi.ac.uk/ena/portal/api/filereport?result=read_run&accession="+wildcards.sample
        urllib.request.urlretrieve(url,"infofiles/"+wildcards.sample+".info")

rule download_fastq:
    input:"infofiles/{sample}.info"
    output:
        "fastq_files/{sample}_1.fastq.gz",
        "fastq_files/{sample}_2.fastq.gz"
    run:
        info_df=pd.read_table(str(input), sep='\t')
        ftp_links=info_df['fastq_ftp'][0].split(";")
        md5_sums=info_df['fastq_md5'][0].split(";")
        for i in [0,1]:
            path_fastq = "http://"+ftp_links[i]
            name = 'fastq_files/'+path_fastq.split('/')[-1]
            md5= md5_sums[i]
            retries=20
            while(retries > 0):
                try:
                    urllib.request.urlretrieve(path_fastq,name)
                    with open(name, 'rb') as file_to_check:
                        data = file_to_check.read()
                        md5_returned = str(hashlib.md5(data).hexdigest())
                    if md5_returned==md5:
                        print("Fetched " + name)
                        break
                except:
                    print("Retrying download from " + path_fastq)
                    retries = retries - 1
                    continue

rule uncompress_fastq:
    input:
        read1="fastq_files/{sample}_1.fastq.gz",
        read2="fastq_files/{sample}_2.fastq.gz"
    output:
        "fastq_files/{sample}_1.fastq",
        "fastq_files/{sample}_2.fastq"
    shell:
        """gunzip -k {input.read1}
        gunzip -k {input.read2}"""

# this step downloads a genome for the particular analysis
# in this case it is A. baumannii but can be changed as needed
rule download_genome:
    output:
        zipped="genome/GCF_001593425.2_ASM159342v2_genomic.gbff.gz",
        unzipped="genome/GCF_001593425.2_ASM159342v2_genomic.gbff"
    shell:
        '''
        wget -O {output.zipped} https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/001/593/425/GCF_001593425.2_ASM159342v2/GCF_001593425.2_ASM159342v2_genomic.gbff.gz
        gunzip -k {output.zipped}
        '''

# this uses a custom script to parse the bacterial genome to a transcriptome
rule generate_transcriptome:
    input: "genome/GCF_001593425.2_ASM159342v2_genomic.gbff"
    output: "genome/GCF_001593425.2_ASM159342v2_genomic_transcripts.fasta"
    shell:
        '''./src/parse_gbff_transcripts.py {input}'''

rule index_transcriptome:
    input: "genome/GCF_001593425.2_ASM159342v2_genomic_transcripts.fasta"
    output: "salmon_indexing_done"
    conda: "envs/salmon.yml"
    shell:
        """
        salmon index -t {input} -i salmon_transcriptome_index -k 31 && touch salmon_indexing_done
        """
        
# Trimming adapters or filtering sequences should not be necessary for mapping of transcripts 
rule map_reads:
    input:
        read1="fastq_files/{sample}_1.fastq",
        read2="fastq_files/{sample}_2.fastq",
    params:
        outdir="{sample}_quant"
    output: "{sample}_quant/quant.sf"
    conda: "envs/salmon.yml"
    shell: """salmon quant -i "salmon_transcriptome_index" -l A -1 {input.read1} -2 {input.read2} -o {params.outdir}"""
    
```
