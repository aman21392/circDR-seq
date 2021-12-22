#!/bin/bash
target=$1 #######(forward_less_20.txt)###########
query=$2  #######(transcript.txt)################
genome=$3 #######(genome.fa)#####################
code=$4
echo "query: "$query
echo "target: "$target
echo "genome: "$genome
echo "code: "$code
for transcript in `cat $query`
do
echo $transcript
echo "var exons=[" > script_"$transcript".js
for exon in `grep "$transcript" $target|sort -k6n,6|sed 's/\t/\_/g'`
do
#echo $exon
echo $exon|sed 's/\_/\t/g'|cut -f 1-3 > coords.bed
seq=`bedtools getfasta -fi $genome -bed coords.bed -tab|cut -f 2`
rm coords.bed
exonnum=`echo $exon|sed 's/\_/\t/g'|cut -f 6`
coordinate=`echo $exon|sed 's/\_/\t/g'|cut -f 1-3 |tr '\t ' '-'`
echo "{\"name\":\"exon"$exonnum"_"$transcript"_$coordinate\",\"seq\":\""$seq"\"}," >> script_"$transcript".js
done
sed -i '$ s/.$//' script_"$transcript".js
echo "    ];" >> script_"$transcript".js
cat $code >> script_"$transcript".js
jjs script_"$transcript".js |awk '{if(NR==1) {print $0} else {if($0 ~ /^>/) {print "\n"$0} else {printf $0}}}'|awk -v OFS="\n" '/^>/ {getline seq}{L=length(seq); L2=int(L/2); print $0, substr(seq,L2+1) substr(seq,1,L2) }'|awk -v OFS="\n" '/^>/ {getline seq}{print $0,substr(seq,length(seq)/2-50,100)}'|awk 'BEGIN{OFS=""} {if($0 ~ /^>/){ n=split($0,a,"|"); print a[1],"|",a[n-1] } else {print $0}}' >>forward.exon.fa
rm script_"$transcript".js
done

cat forward.exon.fa |paste -d $'\t' - - | sort -t $'\t' -uk1,1 | awk 'BEGIN{FS="\t";OFS="\n"}{print $1,$2}' >uniq.header.forward.exon.fa
/home/aclab/bbmap/dedupe.sh in=uniq.header.forward.exon.fa out=uniq.seq.forward.exon.fa
awk '/^>/ {printf("%s%s\t",(N>0?"\n":""),$0);N++;next;} {printf("%s",$0);} END {printf("\n");}' uniq.seq.forward.exon.fa |tr "\t" "\n" >uniq.forward.exon.fa

rm uniq.header.forward.exon.fa uniq.seq.forward.exon.fa
