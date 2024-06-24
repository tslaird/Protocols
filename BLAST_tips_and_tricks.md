## Ordering of output format columns for output format 6 (see: https://www.metagenomics.wiki/tools/blast/blastn-output-format-6)
### if you have ncbi taxonomy databases available
-outfmt "6 qseqid qgi qacc sseqid sallseqid sgi sallgi sacc sallacc stitle salltitles qstart qend sstart send length qlen slen qseq sseq btop frames qframe sframe sstrand evalue bitscore score pident nident mismatch positive gapopen gaps ppos qcovs qcovhsp qcovus sskingdoms staxids sscinames scomnames sblastnames"
### if you don't have the need for ncbi taxonomy mapping
### if you have ncbi taxonomy databases available
-outfmt "6 qseqid qgi qacc sseqid sallseqid sgi sallgi sacc sallacc stitle salltitles qstart qend sstart send length qlen slen qseq sseq btop frames qframe sframe sstrand evalue bitscore score pident nident mismatch positive gapopen gaps ppos qcovs qcovhsp qcovus scomnames sblastnames"
