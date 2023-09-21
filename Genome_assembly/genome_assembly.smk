# Define a list of sample names
SAMPLES = ["SRR12060204"]

rule all:
    input:
        expand("{sample}_quast/report.tsv", sample=SAMPLES)

# Rule to run Fastp for quality control
rule fastp:
    input:
        fastq1 = "{sample}_1.fastq.gz",
        fastq2 = "{sample}_2.fastq.gz"
    output:
        report = "{sample}_fastp.html",
        trimmed_fastq1 = "{sample}_1_trimmed.fastq.gz",
        trimmed_fastq2 = "{sample}_2_trimmed.fastq.gz"
    shell:
        '''
        fastp --in1 {input.fastq1} --in2 {input.fastq2} --out1 {output.trimmed_fastq1} --out2 {output.trimmed_fastq2} --html {output.report} --json {output.report}.json --detect_adapter_for_pe
        '''

# Rule to run SPAdes for genome assembly
rule spades:
    input:
        fastq1 = rules.fastp.output.trimmed_fastq1,
        fastq2 = rules.fastp.output.trimmed_fastq2
    output:
        directory= "{sample}_spades",
        contigs = "{sample}_spades/contigs.fasta"
    params:
        spades_args = "--careful"  # You can customize SPAdes parameters here
    shell:
        '''
        spades.py -o {output.directory} -1 {input.fastq1} -2 {input.fastq2} {params.spades_args}
        '''

# Rule to run QUAST for genome quality assessment
rule quast:
    input:
        assembly = rules.spades.output.contigs
    output:
        quast_results = "{sample}_quast/report.tsv"
    shell:
        '''
        quast.py -o {output.quast_results} {input.assembly}
        '''
