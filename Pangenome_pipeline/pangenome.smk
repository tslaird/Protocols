THRESHOLDS=["0.4","0.5"]
INPUT_FASTA= "all_proteins.fasta"

rule all_mmseqs:
    input:
        expand("resultsDB_clu-{identity}.tsv", identity=THRESHOLDS),
        "master_DB",
        expand("resultsDB_clu-{identity}.pangenome", identity=THRESHOLDS),
        expand("fasttree-log-{identity}.txt", identity=THRESHOLDS),
        expand("treecluster-log-{identity}.txt", identity=THRESHOLDS),
        expand("resultsDB_phyloclu-{identity}.pangenome", identity=THRESHOLDS)

rule make_mmseqs_db:
    input: INPUT_FASTA
    output: "master_DB"
    shell:
        '''
        mmseqs createdb {input} {output}
        '''

rule run_mmseqs:
    input: "master_DB"
    output:"resultsDB_clu-{identity}.tsv"
    shell:
        '''
        mmseqs cluster -c 0.8 -e 0.001 --min-seq-id {wildcards.identity} --threads 4 -v 3 master_DB resultsDB_aln-{wildcards.identity} resultsDB_clu-{wildcards.identity} &&
        mmseqs createtsv master_DB master_DB resultsDB_aln-{wildcards.identity} resultsDB_clu-{wildcards.identity}.tsv
        '''

rule parse_mmseqs:
    input:
        tsv="resultsDB_clu-{identity}.tsv",
        fasta = INPUT_FASTA
    output:
        file="resultsDB_clu-{identity}.pangenome",
        directory=directory("Cluster_seqs-{identity}/")
    run:
        import pandas as pd
        import time
        def jaccard(list1, list2):
            intersection = len(list(set(list1).intersection(list2)))
            union = (len(list1) + len(list2)) - intersection
            return float(intersection) / union

        def getNewick(node, newick, parentdist, leaf_names):
            if node.is_leaf():
                return "%s:%.2f%s" % (leaf_names[node.id], parentdist - node.dist, newick)
            else:
                if len(newick) > 0:
                    newick = "):%.2f%s" % (parentdist - node.dist, newick)
                else:
                    newick = ");"
                newick = getNewick(node.get_left(), newick, node.dist, leaf_names)
                newick = getNewick(node.get_right(), ",%s" % (newick), node.dist, leaf_names)
                newick = "(%s" % (newick)
                return newick
        with open(str(input.fasta),'r') as fastaIN:
            seqsIN = fastaIN.read()
        seqsLIST = seqsIN.split("\n\n")
        del(seqsLIST[-1])
        ID = [s.split("\n", 1)[0] for s in seqsLIST]
        SEQ = [s.split("\n",1)[1] for s in seqsLIST]
        seqDICT = dict(zip(ID, SEQ))
        mmseqs_out=pd.read_csv(str(input.tsv), sep='\t', header=None)
        mmseqs_out.columns = ['rep','match']
        rep_factor = pd.factorize(mmseqs_out['rep'])
        mmseqs_out['rep_factor']= rep_factor[0]
        cluster_df = pd.DataFrame(rep_factor[1])
        cluster_df['rep_factor'] = cluster_df.index
        cluster_df.columns = ['protein','cluster']
        rep_df = mmseqs_out[['match','rep_factor']]
        rep_df.columns=['protein','cluster']
        #all_cluster_df = pd.concat([rep_df,cluster_df],axis=0)
        all_cluster_df=rep_df
        all_cluster_df[["accession","assembly","name","synteny","protein_name","protein_id"]] = all_cluster_df['protein'].str.split("!!", expand = True)
        all_genomes=set(all_cluster_df['protein'].str.split("!!", expand = True)[2])
        all_clusters =  list(range(0, max(all_cluster_df['cluster'])))
        print(all_genomes)
        #print(all_clusters)
        if not os.path.exists(output.directory):
            os.mkdir(output.directory)
        def catalog_cluster(cluster):
            print(str(cluster)+'\n')
            time.sleep(0.001)
            rep_names_full= list(cluster_df[cluster_df['cluster']==cluster]['protein'])[0]
            rep_names =rep_names_full.split('!!')[5]
            genome_tally=[]
            genome_pids=[]
            genome_cluster_df=all_cluster_df[all_cluster_df['cluster']==cluster]
            #print(seqDICT)
            seqOUT = [">"+z+"\n"+seqDICT[">"+z] for z in genome_cluster_df['protein'] ]
            with open(output.directory+"/Cluster_"+str(cluster)+"_seqs.fasta",'w') as clustOUT:
                clustOUT.write("\n\n".join(seqOUT))
            for genome in all_genomes:
                if genome in list(genome_cluster_df['name']):
                    pids=genome_cluster_df[ genome_cluster_df['name']== genome]['protein_id'].tolist()
                else:
                    pids=''
                genome_pids.append(" ".join(pids))
                genome_tally.append(len(pids))
            return(["Cluster_"+str(cluster)]+[rep_names]+[rep_names_full]+genome_tally+genome_pids)
            #return(["Cluster_"+str(cluster_id)]+rep_names+rep_full_names+genome_tally+genome_pids)
        #catalog_cluster(1)
        result_list=[]
        #print(result_list)
        #with concurrent.futures.ProcessPoolExecutor(max_workers=1) as executor:
        #    for i in executor.map(catalog_cluster, all_clusters):
        #        result_list.append(i)
        #        pass
        for i in all_clusters:
            j = catalog_cluster(i)
            result_list.append(j)
        names=['cluster_id']+['rep_name']+['full_name']+list(all_genomes)+[i+"_loci" for i in all_genomes]
        #names=['cluster_id']+list(all_genomes)
        output_df=pd.DataFrame(result_list, columns= names)
        rowcount = (output_df.iloc[:,3:int((len(output_df.columns)-3)/2)] >0).sum(axis=1)
        output_df.insert(3, 'count', rowcount)
        output_df.to_csv(str(output.file))


#could be made better with snakemake
rule fasttree_treecluster:
    input: "Cluster_seqs-{identity}/"
    output: "fasttree-log-{identity}.txt"
    shell:
        '''
        for file in {input}/*seqs.fasta;
        do
            num=$(grep ">" $file | wc -l)
            if [[ $num > 1 ]]; then
                muscle -in ${{file}} -out ${{file}}.msa && trimal -in ${{file}}.msa -automated1 > ${{file}}.trim.msa && fasttree ${{file}}.trim.msa > ${{file}}.trim.msa.fasttree.tree
            fi
        done
        touch {output}
        '''

rule filt_treecluster:
    input:
        A= "Cluster_seqs-{identity}/",
        B= "fasttree-log-{identity}.txt"
    conda: "treecluster.yml"
    output: "treecluster-log-{identity}.txt"
    shell:
        '''
        for file in {input.A}*fasttree.tree;
        do
            TreeCluster.py -i ${{file}} -t 1 -o ${{file}}.1.treecluster --method length
            TreeCluster.py -i ${{file}} -t 0.9 -o ${{file}}.0.9.treecluster --method length
            TreeCluster.py -i ${{file}} -t 0.85 -o ${{file}}.0.85.treecluster --method length
            TreeCluster.py -i ${{file}} -t 0.7 -o ${{file}}.0.7.treecluster --method length
        done
        touch {output}
        '''

rule repartition_clusters:
    input:
        A= "Cluster_seqs-{identity}/",
        B= "treecluster-log-{identity}.txt"
    output: "repartition-log-{identity}.txt"
    run:
        treeclust_files = glob.glob(input.A+'/*0.7.treecluster')
        out_list =[]
        for f in treeclust_files:
            print("_".join(f.split("_")[0:2]))
            f_df = pd.read_csv(f, sep='\t')
            singleton_len = len(f_df[f_df['ClusterNumber'] == -1])
            #print(singleton_len)
            f_df['ClusterNumber'] = [m if m != -1 else str(m)+str(randint(0,20000)) for m in f_df['ClusterNumber']]
            ids = f_df['ClusterNumber'].unique().tolist()
            for i in ids:
                clust_df = f_df.loc[f_df.ClusterNumber == i]
                clust_rep = clust_df['SequenceName'].iloc[0]
                for j in clust_df['SequenceName']:
                    out_list.append([clust_rep,j ])
        new_clusters_df = pd.DataFrame(out_list)
        new_clusters_df.to_csv('resultsDB_phyloclu-{identity}.tsv', header=False, index=False, sep = '\t')


rule parse_mmseqs_phyloclust:
    input:
        tsv="resultsDB_phyloclu-{identity}.tsv",
        fasta = INPUT_FASTA
    output:"resultsDB_phyloclu-{identity}.pangenome"
    run:
        def jaccard(list1, list2):
            intersection = len(list(set(list1).intersection(list2)))
            union = (len(list1) + len(list2)) - intersection
            return float(intersection) / union

        def getNewick(node, newick, parentdist, leaf_names):
            if node.is_leaf():
                return "%s:%.2f%s" % (leaf_names[node.id], parentdist - node.dist, newick)
            else:
                if len(newick) > 0:
                    newick = "):%.2f%s" % (parentdist - node.dist, newick)
                else:
                    newick = ");"
                newick = getNewick(node.get_left(), newick, node.dist, leaf_names)
                newick = getNewick(node.get_right(), ",%s" % (newick), node.dist, leaf_names)
                newick = "(%s" % (newick)
                return newick
        with open(str(input.fasta),'r') as fastaIN:
            seqsIN = fastaIN.read()
        seqsLIST = seqsIN.split("\n\n")
        del(seqsLIST[-1])
        ID = [s.split("\n", 1)[0] for s in seqsLIST]
        SEQ = [s.split("\n",1)[1] for s in seqsLIST]
        seqDICT = dict(zip(ID, SEQ))
        mmseqs_out=pd.read_csv(str(input.tsv), sep='\t', header=None)
        mmseqs_out.columns = ['rep','match']
        rep_factor = pd.factorize(mmseqs_out['rep'])
        mmseqs_out['rep_factor']= rep_factor[0]
        cluster_df = pd.DataFrame(rep_factor[1])
        cluster_df['rep_factor'] = cluster_df.index
        cluster_df.columns = ['protein','cluster']
        rep_df = mmseqs_out[['match','rep_factor']]
        rep_df.columns=['protein','cluster']
        #all_cluster_df = pd.concat([rep_df,cluster_df],axis=0)
        all_cluster_df=rep_df
        all_cluster_df[["accession","assembly","name","synteny","protein_name","protein_id"]] = all_cluster_df['protein'].str.split("!!", expand = True)
        all_cluster_df['unique_id'] = all_cluster_df['name'] + all_cluster_df['synteny']
        all_genomes=set(all_cluster_df['unique_id'])
        #all_genomes=set(all_cluster_df['protein'].str.split("!!", expand = True)[2])
        all_clusters =  list(range(0, max(all_cluster_df['cluster'])))
        print(all_genomes)
        #print(all_clusters)
        if not os.path.exists("PhyloCluster_seqs/"):
            os.mkdir("PhyloCluster_seqs/")
        def catalog_cluster(cluster):
            print(str(cluster)+'\n')
            #time.sleep(0.001)
            rep_names_full= list(cluster_df[cluster_df['cluster']==cluster]['protein'])[0]
            rep_names =rep_names_full.split('!!')[5]
            genome_tally=[]
            genome_pids=[]
            genome_cluster_df=all_cluster_df[all_cluster_df['cluster']==cluster]
            #print(seqDICT)
            seqOUT = [">"+z+"\n"+seqDICT[">"+z] for z in genome_cluster_df['protein'] ]
            with open("PhyloCluster_seqs/Cluster_"+str(cluster)+"_seqs.fasta",'w') as clustOUT:
                clustOUT.write("\n\n".join(seqOUT))
            for genome in all_genomes:
                if genome in list(set(all_cluster_df['unique_id'])):
                    #print(genome)
                    pids=genome_cluster_df[ genome_cluster_df['unique_id']== genome]['protein_id'].tolist()
                else:
                    pids=''
                genome_pids.append(" ".join(pids))
                #print(pids)
                genome_tally.append(len(pids))
                #print(len(pids))
            return(["Cluster_"+str(cluster)]+[rep_names]+[rep_names_full]+genome_tally+genome_pids)
            #return(["Cluster_"+str(cluster_id)]+rep_names+rep_full_names+genome_tally+genome_pids)
        #catalog_cluster(1)
        result_list=[]
        #print(result_list)
        #with concurrent.futures.ProcessPoolExecutor(max_workers=1) as executor:
        #    for i in executor.map(catalog_cluster, all_clusters):
        #        result_list.append(i)
        #        pass
        for i in all_clusters:
            j = catalog_cluster(i)
            result_list.append(j)
        names=['cluster_id']+['rep_name']+['full_name']+list(all_genomes)+[i+"_loci" for i in all_genomes]
        #names=['cluster_id']+list(all_genomes)
        output_df=pd.DataFrame(result_list, columns= names)
        rowcount = (output_df.iloc[:,3:int((len(output_df.columns)-3)/2)] >0).sum(axis=1)
        output_df.insert(3, 'count', rowcount)
        output_df.to_csv(str(output))

# rule edit_clustseq:
#     input: directory("Cluster_seqs")
#     threads:1
#     shell:
#         '''
#         for f in Cluster_seqs/*_seqs.fasta;
#         do
#             base=$(basename "$f" "_seqs.fasta")
#             sed "s/>/>$base\!\!/g" $f > "Cluster_seqs/${{base}}.fa"
#         done
#         '''
