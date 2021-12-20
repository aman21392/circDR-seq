#!/bin/bash
target=$1 
fwtranscript=$2 
revtranscript=$3 
gene=$4 
database=$5 
echo "target: "$target
echo "fwtranscript: "$fwtranscript
echo "revtranscript: "$revtranscript
echo "gene: "$gene
echo "database: "$database

grep -f $fwtranscript $target >forward.circRNA.psl
grep -f $revtranscript $target >reverse.circRNA.psl
cat reverse.circRNA.psl |awk '{print $14}' |sed 's/|/\t/g'|awk '{print $2,$1}'| sed 's/ /|/g' >read.reverse.20exon.psl
awk '{print $14}' forward.circRNA.psl|awk -F "[_|-]+"  '{print $2,$3,(int($4)<int($9)?$4:$9),(int($5)>int($10)?$5:$10)}' |sort|sed -e 's/ /\t/g' >forward.coordinate.txt
awk '{print $1}' read.reverse.20exon.psl|awk -F "[_|-]+"  '{print $2,$3,(int($4)<int($9)?$4:$9),(int($5)>int($10)?$5:$10)}' |sort|sed -e 's/ /\t/g' >reverse.coordinate.txt
join forward.coordinate.txt $4 | awk '{print $1,$2,$3,$4,$5}' |awk '{print $2,$3,$4,$5}' |uniq -c |awk '{print $2,$3,$4,$1,$5}' |sed -E 's/\s+/\t/g'|awk '{print $1,$2,$3,$5,$4}'|sed -E 's/\s+/\t/g' >forward.gene.count.txt
join reverse.coordinate.txt $4 | awk '{print $1,$2,$3,$4,$5}' |awk '{print $2,$3,$4,$5}' |uniq -c |awk '{print $2,$3,$4,$1,$5}' |sed -E 's/\s+/\t/g'|awk '{print $1,$2,$3,$5,$4}'|sed -E 's/\s+/\t/g' >reverse.gene.count.txt
cat forward.gene.count.txt reverse.gene.count.txt |sort -n -k1 |sed -E 's/\s+/\t/g' >20exon.gene.count.txt
bedtools intersect -a 20exon.gene.count.txt -b $database -f 1 -r -v >unique.20exon.circRNA.txt
bedtools intersect -a 20exon.gene.count.txt -b $database -f 1 -r -wa -wb |awk '{print $1,$2,$3,$4,$5,$10,$11}'|sed -E 's/\s+/\t/g' >20exon.database.circRNA.txt
cat unique.20exon.circRNA.txt 20exon.database.circRNA.txt| sort -n -k1 |awk -F'\t' 'BEGIN{OFS=FS} $6 == "" {$6 = "NA"} 1'|awk -F'\t' 'BEGIN{OFS=FS} $7 == "" {$7 = "NA"} 1' |sed -E 's/\s+/\t/g'>exonic.circRNA.list.txt


rm forward.circRNA.psl reverse.circRNA.psl read.reverse.20exon.psl forward.coordinate.txt reverse.coordinate.txt forward.gene.count.txt reverse.gene.count.txt 20exon.database.circRNA.txt 20exon.gene.count.txt
