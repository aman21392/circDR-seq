#!/bin/bash
# written by Aman Kumar Singh
# First written on 1st December 2021

output=$1
target=$2
query=$3
echo "output: "$output
echo "target: "$target
echo "query: "$query
####################### sh precision.sh $query.overlap.mismatch.gap.psl ######################################
awk '{print $10,$14}' $output |sed 's/|/\t/g' | awk '{print $1,$5}' |sort |sed 's/-/_/g' |tr ' ' '\t' | tr "\\t" "," >data.csv

{ echo "read,circBase"; cat data.csv; } > final.csv

cat final.csv | csvtk mutate2 -n match -L 0 -e '$read == $circBase ? 1 : 0'| csvtk mutate2 -n not_match -L 0 -e '$read == $circBase ? 0 : 1' | csvtk summary -g read -n 0 -f match:sum -f not_match:sum| csvtk rename2  -f -read -p ':sum' >precision.csv

awk -F',' '{sum+=$2;}END{print sum;}' precision.csv >TP.txt

awk -F',' '{sum+=$3;}END{print sum;}' precision.csv >FP.txt

paste -d+ TP.txt FP.txt | bc >total_count.txt

paste TP.txt total_count.txt | awk '{print($1/$2)}' >precision_ratio.txt

cat precision.csv |sed 's/\,/\t/g' | awk '$2!=0'|awk '{print $1}'|sed '1d' >circRNA.list.txt

################################### recall ratio calculate ##########################################################

samtools faidx $target

awk '{print $1, $2}' $target.fai >$target.txt

awk '{for(i=2;i<=NF;i++)$i/=2}1' $target.txt |awk 'BEGIN{OFS="\t"} {gsub("\\.[0-9]+$", "", $2); print}' |sed 's/|/\t/g'|awk '{print $1,$5}'>$target.halflength.txt

awk '{ print  $2 + 20}' $target.halflength.txt >$target.halflength20add.txt
awk '{ print $1, $2 - 20}' $target.halflength.txt >$target.halflength20minus.txt
paste $target.halflength20minus.txt $target.halflength20add.txt |sed 's/ /\t/g'>$target.halflength.coord.txt 

samtools faidx $query
awk '{print $1, $2}' $query.fai >$query.txt

cat $query.txt |sed 's/;/\t/g'|awk '{print $1,$3}' |sed 's/_/\t/g'|awk '{print $1,$2,$3}' | sed 's/|/\t/g'|awk '{print $1,$5,$6}'|sed 's/-/_/g' >$query.pre.txt
awk '{ print $0, $2 + $3}' $query.pre.txt |awk '{print $1, $2, $4}'|sed 's/ /\t/g' >$query.final.txt

bedtools intersect -b $query.final.txt -a $target.halflength.coord.txt -f 1 -c -wa |awk '$4!=0' |awk '{print $1}'>intersect.txt
########################### For recalling percentage #######################################
gawk 'NR==FNR{a+=1;next} {b+=1} END{printf "%.2f\n", a/b}' circRNA.list.txt intersect.txt >recall_ratio.txt

########################### Delete Temp file ########################
rm data.csv final.csv TP.txt FP.txt total_count.txt precision.csv
rm intersect.txt $query.final.txt $query.pre.txt $query.txt $target.halflength.coord.txt $target.halflength20minus.txt $target.halflength20add.txt  $target.halflength.txt circRNA.list.txt $target.fai $target.txt $query.fai
