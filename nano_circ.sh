#!/bin/bash
query=$2
target=$1
echo "query: "$query
echo "target: "$target
##################use of pblat to align the query on the target sequence #################################
pblat -threads=70 -minScore=60 -minIdentity=80 $target $query $query.psl

########### use awk command to get only those sequence which span the backplice junction of 20bp upstream and 20bp downstream #############################
awk '$16<=30 && $17>=70' $query.psl >$query.overlap.psl

############### use of awk command to remove those sequences which have >0.2 mismatches in the alignment ##############################
cat $query.overlap.psl |awk '$2/($1+$2)<0.2{print $0}' >$query.overlap.mismatch.psl

############### use of awk command to remove those sequences which have >20 gaps in qury and >10 gaps in target sequences for removal of false positive #####################
awk '$6<20 && $8<20' $query.overlap.mismatch.psl > $query.overlap.mismatch.gap.psl

################### extract the target column and know about the count of circRNA #####################################
awk '{print $14}' $query.overlap.mismatch.gap.psl |sed 's/|/\t/g' | awk '{print $1}' |sort |uniq -c >$query.count.txt

rm $query.psl $query.overlap.psl $query.overlap.mismatch.psl
