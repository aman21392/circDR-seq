#!/bin/bash
circbase=$1
circbasedatabase=$2
circatlas=$3
circatlasdatabase=$4
echo "circbase: "$circbase
echo "circbasedatabase: "$circbasedatabase
echo "circatlas: "$circatlas
echo "circatlasdatabase: "$circatlasdatabase

for i in `cat $circbase|awk '{print $1, $2}'|sed 's/ /\#/g'`
do
count=`echo $i|cut -f 1 -d '#'`
id=`echo $i|cut -f 2 -d '#'`
coords=`grep $id $circbasedatabase`
echo "$count  $coords"|awk -F'\t' '$2 != ""'|sed 's/chr//g'|awk '{print $2,$3,$4,$5,$1,$6}'|sed -E 's/\s+/\t/g' |sed 's/[\t]*$//' >>circBase.txt
done

for i in `cat $circatlas|awk '{print $1, $2}'|sed 's/ /\#/g'`
do
count=`echo $i|cut -f 1 -d '#'`
id=`echo $i|cut -f 2 -d '#'`
coords=`grep $id $circatlasdatabase`
echo "$count  $coords"|awk -F'\t' '$2 != ""'|sed 's/chr//g'|awk '{print $2,$3,$4,$5,$1,$6}'|sed -E 's/\s+/\t/g'|sed 's/[\t]*$//' >>circatlas.txt
done

bedtools intersect -a circBase.txt -b circatlas.txt -f 1 -r -loj |awk '{print $1,$2,$3,$4,$5,$6,$12}' |awk '{ if ( $7 != "." ) { print $0; } }' |sed -e 's/ /\t/g' >circbase.circatlas.txt
bedtools intersect -b circBase.txt -a circatlas.txt -f 1 -r -v  -wa |sed 's/\t/\t\t/5' >circatlas.intersect.txt
bedtools intersect -b circatlas.txt -a circBase.txt -f 1 -r -v -wa >circBase.intersect.txt
cat circbase.circatlas.txt circBase.intersect.txt circatlas.intersect.txt | sort -n -k1 |awk -F'\t' 'BEGIN{OFS=FS} $6 == "" {$6 = "NA"} 1'|awk -F'\t' 'BEGIN{OFS=FS} $7 == "" {$7 = "NA"} 1'>database.circRNA.list.txt

rm circbase.circatlas.txt circatlas.intersect.txt circBase.intersect.txt
