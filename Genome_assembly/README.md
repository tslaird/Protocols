# Genome assembly

The snakefile in this folder enables assembly of bacterial genomes from raw reads. The main steps are as follows:

1) Trimmimg and quality control with fastp
2) Assembly with spades
3) Obtaining assembly statistics with quast
