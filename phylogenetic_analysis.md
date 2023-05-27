Here is a template Snakemake workflow for creating phylogenetic trees from an input protein fasta file:

```
PROTEINS = [ ] 

rule all_phylo:
    input:
         expand("{protein}.trim.msa.treefile",protein=PROTEINS),
         expand("{protein}.trim.msa.fasttree.nwk",protein=PROTEINS)


rule align:
    input: "{protein}_seqs.fa"
    output:"{protein}_seqs.msa.fa"
    shell:
        '''muscle -in {input} -out {output}'''


rule trim_alignment:
    input: "{protein}.msa.fa"
    output: "{protein}.trim.msa.fa"
    shell:
      '''trimal -in {input} -automated1 > {output}'''
    

rule make_nexus:
    input: "{protein}.trim.msa.fa"
    output: "{protein}.trim.msa.nex"
    shell:
        '''seqmagick convert --output-format nexus --alphabet protein {input} {output}

rule build_fasttree:
    input:"{protein}_seqs.trim.msa.fa"
    output: "{protein}_seqs.trim.msa.fasttree.nwk"
    shell:
        '''FastTree {input} > {output} '''

rule build_iqtree:
    input:"{protein}_seqs.trim.msa.fa"
    output: "{protein}_seqs.trim.msa.treefile"
    shell:
        '''iqtree2 -s {input} --ufboot 1000 -alrt 1000 '''

```
