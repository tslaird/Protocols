# Pangenome_pipeline

This folder contains a snakemake workflow for clustering bacterial proteomes to create a pangenome matrix.

Note: the genomes must be compiled from ".gbff" files using the parse_gbff() function in the ClusterSearch package. Once all the genomes are parsed they can be combined into a file such as "all_proteins.fasta" which can then be used in this workflow as the INPUT_FILE.

There are several steps to this workflow which are generally outlined below:
1) clustering of proteins using mmseqs at various thresholds as defined in the snakefile ("THRESHOLDS" variable)
2) creation of a pangenome matrix using the mmseqs clustering as a direct input
3) alignemnt, trimming, and tree construction of each mmseqs created cluster
4) dividing clusters into subclusters using the treeclustering program
5) creating an additional pangenome matrix based on the treeclustering output

to run the analysis you can execute something like:
```snakemake -s pangenome.smk --cores 2 --use-conda```
