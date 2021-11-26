# Version 1.0
# pblat - BLAT with parallel supports v. 36x2
#!/bin/bash
query= file_name_of_query
target= path_of_target_fasta_sequence
echo "query: "$query
echo "target: "$target
##################use of pblat to align the query on the target sequence #################################
/home/aclab/pblat-master/pblat -threads=70 -minScore=60 -minIdentity=80 $target $query.fasta $query.psl

########### use awk command to get only those sequence which span the backplice junction of 20bp upstream and 20bp downstream #############################
awk '$16<=30 && $17>=70' $query.psl >$query.overlap.psl

############### use of awk command to remove those sequences which have >0.2 mismatches in the alignment ##############################
cat $query.overlap.psl |awk '$2/($1+$2)<0.2{print $0}' >$query.overlap.mismatch.psl

############### use of awk command to remove those sequences which have >20 gaps in query and >10 gaps in target sequences for removal of false positive #####################
awk '$6<20 && $8<10' $query.overlap.mismatch.psl > $query.overlap.mismatch.gap.psl

################### extract the target column and know about the count of circRNA #####################################
awk '{print $14}' $query.overlap.mismatch.gap.psl |sed 's/|/\t/g' | awk '{print $1}' |sort |uniq -c >$query.count.txt

