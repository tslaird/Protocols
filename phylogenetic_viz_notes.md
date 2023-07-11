# ggtree
for metadata mapping the tiplabels must correspond to the "taxon" column in the metadata data frame,
and the "taxon" column must be the first column in the data frame.

## extracting leaf tip names according to order
https://rdrr.io/github/joelnitta/jntools/man/get_tips_in_ape_plot_order.html

## a code snippet to automatically find/create clade labels for tips that have the same name
the code requires the ape and phytools package for parsing the tree
```
tree_list<-subtrees(tree)
summary_node_list<-c()
for(i in tree_list){
  unique_tips<-length( unique(i$tip.label) )
  if(unique_tips==1){
    summary_node_list[[length(summary_node_list) + 1]]<-c(i$name,unique(i$tip.label),list(i$node.label) )
  }
}
df<-as.data.frame(do.call(rbind,summary_node_list))
df$V4<-sapply( df$V1, function(x) sum(unlist(df$V3)==x))
df<-df[df$V4==1,]

# get the tips that are downstream of the broadly labeled nodes
broad_label_ids<-unlist(sapply(unlist(df$V1), function(x) getDescendants(tree,x)[getDescendants(tree,x)<=length(tree$tip.label)]))

# then add the clade labels to a ggtree object using a for loop

for(i in c(1:nrow(df))){
  pt<-pt + geom_cladelabel(as.numeric(df[i,1]), df[i,2],offset=0.005, fontsize = 5 )
}
pt

```
