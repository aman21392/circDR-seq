#!/bin/bash
database=$1 
exon=$2
echo "database: "$database
echo "exon: "$exon
bedtools intersect -a $exon -b $database -f 1 -r -v -wa >exonic.circRNA.txt
bedtools intersect -b $exon -a $database -f 1 -r -wa >database.circRNA.txt
bedtools intersect -b $exon -a $database -f 1 -r -v -wa >only.database.circRNA.txt
cat exonic.circRNA.txt database.circRNA.txt only.database.circRNA.txt| sort -n -k1 |sed -E 's/\s+/\t/g'>complete.list.circRNA.txt
sed  -i '1i chromosome_no. \tgene_start \tgene_end \tgene_name \tcount \tcircBase_id \tcircAtlas_id' complete.list.circRNA.txt

rm exonic.circRNA.txt database.circRNA.txt only.database.circRNA.txt