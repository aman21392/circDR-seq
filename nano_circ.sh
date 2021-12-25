#!/bin/bash
# written by Aman Kumar Singh
# First written on 1st December 2021

query=$2
target=$1
echo "query: "$query
echo "target: "$target
##################use of pblat to align the query on the target sequence #################################
pblat -threads=70 -minScore=60 -minIdentity=80 $target $query $query.psl

########### use awk command to get only those sequence which span the backplice junction of 20bp upstream and 20bp downstream #############################
awk '$16<=30 && $17>=70' $query.psl >$query.overlap.psl

############### use of awk command to remove those sequences which have >0.1 mismatches in the alignment ##############################
cat $query.overlap.psl |awk '$2/($1+$2)<0.1{print $0}' >$query.overlap.mismatch.psl

############### use of awk command to remove those sequences which have >20 gaps in qury and >20 gaps in target sequences for removal of false positive #####################
awk '$6<20 && $8<20' $query.overlap.mismatch.psl > $query.overlap.mismatch.gap.psl

############################## use awk to sum the 19th column and make new file ##################################
awk '{print $19}' $query.overlap.mismatch.gap.psl |awk -F , '{ sum = 0; for(i=1; i<=NF; i++) sum += $i; print  sum }' >$query.overlap.mismatch.gap.block.psl

############################# paste the block.psl file into the gap.psl file to make the 22 column psl file #####################################
paste $query.overlap.mismatch.gap.psl $query.overlap.mismatch.gap.block.psl >$query.overlap.mismatch.gap.block.list.psl

############################ use awk to remove reads on the basis od 22nd column ##########################################
awk 'NR==FNR{ max[$10]=(max[$10]>$NF? max[$10]:$NF); next }max[$10]==$NF' $query.overlap.mismatch.gap.block.list.psl $query.overlap.mismatch.gap.block.list.psl >$query.overlap.mismatch.gap.block.list.list.psl

#####################extract unique reads ##################################
awk '{print $10}' $query.overlap.mismatch.gap.block.list.list.psl|sort |uniq -c |awk '$1<=1{print $2}' >read.txt

######################### make a final file from those unique reads ###################################
grep -f read.txt $query.overlap.mismatch.gap.block.list.list.psl >output.psl

################### extract the target column and know about the count of circRNA #####################################
awk '{print $14}'  output.psl|sed 's/|/\t/g' | awk '{print $1}' |sort |uniq -c >$query.count.txt

################# Delete Temp files ########################
rm $query.psl $query.overlap.psl $query.overlap.mismatch.psl read.txt $query.overlap.mismatch.gap.psl $query.overlap.mismatch.gap.block.psl $query.overlap.mismatch.gap.block.list.psl $query.overlap.mismatch.gap.block.list.list.psl read.txt 
