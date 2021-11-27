#!/bin/bash
################## convert of linear fasta sequence into backsplice fasta sequence #################################
target= path_of_linear_target_fasta_file
echo "target: "$target
awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}' $target |awk -v OFS="\n" '/^>/ {getline seq}{L=length(seq); L2=int(L/2); print $0, substr(seq,L2+1) substr(seq,1,L2) }' >$target.backsplice.fa

#################### shorten the backsplice target sequence to 100bp library ########################################
awk -v OFS="\n" '/^>/ {getline seq}{print $0,substr(seq,length(seq)/2-50,100)}' $target.backsplice.fa >$target.backsplice.100bp.fa
