## Ordering of output format columns for output format 6 (see: https://www.metagenomics.wiki/tools/blast/blastn-output-format-6)
### if you have ncbi taxonomy databases available
-outfmt "6 qseqid qgi qacc sseqid sallseqid sgi sallgi sacc sallacc stitle salltitles qstart qend sstart send length qlen slen qseq sseq btop frames qframe sframe sstrand evalue bitscore score pident nident mismatch positive gapopen gaps ppos qcovs qcovhsp qcovus sskingdoms staxids sscinames scomnames sblastnames"
### if you don't have the need for ncbi taxonomy mapping
### if you have ncbi taxonomy databases available
-outfmt "6 qseqid qgi qacc sseqid sallseqid sgi sallgi sacc sallacc stitle salltitles qstart qend sstart send length qlen slen qseq sseq btop frames qframe sframe sstrand evalue bitscore score pident nident mismatch positive gapopen gaps ppos qcovs qcovhsp qcovus scomnames sblastnames"

### full options are below:
 -outfmt <String>
   alignment view options:
     0 = Pairwise,
     1 = Query-anchored showing identities,
     2 = Query-anchored no identities,
     3 = Flat query-anchored showing identities,
     4 = Flat query-anchored no identities,
     5 = BLAST XML,
     6 = Tabular,
     7 = Tabular with comment lines,
     8 = Seqalign (Text ASN.1),
     9 = Seqalign (Binary ASN.1),
    10 = Comma-separated values,
    11 = BLAST archive (ASN.1),
    12 = Seqalign (JSON),
    13 = Multiple-file BLAST JSON,
    14 = Multiple-file BLAST XML2,
    15 = Single-file BLAST JSON,
    16 = Single-file BLAST XML2,
    17 = Sequence Alignment/Map (SAM),
    18 = Organism Report
   
   Options 6, 7, 10 and 17 can be additionally configured to produce
   a custom format specified by space delimited format specifiers,
   or in the case of options 6, 7, and 10, by a token specified
   by the delim keyword. E.g.: "17 delim=@ qacc sacc score".
   The delim keyword must appear after the numeric output format
   specification.
   The supported format specifiers for options 6, 7 and 10 are:
            qseqid means Query Seq-id
               qgi means Query GI
              qacc means Query accession
           qaccver means Query accession.version
              qlen means Query sequence length
            sseqid means Subject Seq-id
         sallseqid means All subject Seq-id(s), separated by a ';'
               sgi means Subject GI
            sallgi means All subject GIs
              sacc means Subject accession
           saccver means Subject accession.version
           sallacc means All subject accessions
              slen means Subject sequence length
            qstart means Start of alignment in query
              qend means End of alignment in query
            sstart means Start of alignment in subject
              send means End of alignment in subject
              qseq means Aligned part of query sequence
              sseq means Aligned part of subject sequence
            evalue means Expect value
          bitscore means Bit score
             score means Raw score
            length means Alignment length
            pident means Percentage of identical matches
            nident means Number of identical matches
          mismatch means Number of mismatches
          positive means Number of positive-scoring matches
           gapopen means Number of gap openings
              gaps means Total number of gaps
              ppos means Percentage of positive-scoring matches
            frames means Query and subject frames separated by a '/'
            qframe means Query frame
            sframe means Subject frame
              btop means Blast traceback operations (BTOP)
            staxid means Subject Taxonomy ID
          ssciname means Subject Scientific Name
          scomname means Subject Common Name
        sblastname means Subject Blast Name
         sskingdom means Subject Super Kingdom
           staxids means unique Subject Taxonomy ID(s), separated by a ';'
                         (in numerical order)
         sscinames means unique Subject Scientific Name(s), separated by a ';'
         scomnames means unique Subject Common Name(s), separated by a ';'
        sblastnames means unique Subject Blast Name(s), separated by a ';'
                         (in alphabetical order)
        sskingdoms means unique Subject Super Kingdom(s), separated by a ';'
                         (in alphabetical order) 
            stitle means Subject Title
        salltitles means All Subject Title(s), separated by a '<>'
           sstrand means Subject Strand
             qcovs means Query Coverage Per Subject
           qcovhsp means Query Coverage Per HSP
            qcovus means Query Coverage Per Unique Subject (blastn only)
   When not provided, the default value is:
   'qaccver saccver pident length mismatch gapopen qstart qend sstart send
   evalue bitscore', which is equivalent to the keyword 'std'
   The supported format specifier for option 17 is:
                SQ means Include Sequence Data
                SR means Subject as Reference Seq
